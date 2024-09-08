function @distance_vec3($pos_0:text, $pos_1:text):number
	; takes object ".x{}.y{}.z{}"
	var $distance = sqrt(pow($pos_1.x - $pos_0.x, 2) + pow($pos_1.y - $pos_0.y, 2) + pow($pos_1.z - $pos_0.z, 2))
	return $distance

function @get_beacon($alias:text): text
	var $results = ""
	$results.position = input_text($alias, 0)
	$results.distance = input_text($alias, 1)
	var $rotation = ""
	$rotation.x = input_text($alias, 2)
	$rotation.y = input_text($alias, 3)
	$rotation.z = input_text($alias, 4)
	$results.rotation = $rotation
	return $results


; Trilat vars
array $trilat_beacons : text ; needs to be an array of beacon data, use @get_beacon and add them all to this
array $results_history : text ; an array of previous results
const $guess_zero = ".x{0}.y{0}.z{0}.error{99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999}" ; Tons of error, anything is better than this

; Trlat helper functions
function @trilat_calc_error($guess:text):number
	; calcs error of current position from beacon input
	; $guess is a vec3 ".x{}.y{}.z{}"
	; https://yogayu.github.io/DeepLearningCourse/04/GradientDescent.html

	var $error = 0
	foreach $trilat_beacons ($index, $beacon)
		$error += pow($beacon.distance - @distance_vec3($guess, $beacon.position), 2)
		
	return $error / $trilat_beacons.size


function @trilat_3d_basic($options:text):text
	; Trilateration as an optimization problem, calculates pos with error
	; $trilat_2d_opti_array is an array with objects like this ".distance{}.position{.x{}.y{}.z{}}"
	; https://www.alanzucconi.com/2017/03/13/positioning-and-trilateration/
	
	; $options needs these, guess is optional ".max_iterations{50}.learning_rate{0.8}.guess{}"
	; guess is of format ".x{0}.y{0}.z{0}"
	
	
	
	
	
	; Tips
	; Learning rate should be around 0.5 - 1.4, extreme values break it
	
	; Max iterations, can be very cpu intensive, over 500 give my pc stutters
	; The higher this is, the quicker error reaches zero
	
	; Example error values (calc is squared so gets big quick)
	; X += 1 ; Error = 0.62
	; X += 10 ; Error = 60
	; X += 100 ; Error = 5879
	; X += 1000 ; Error = 481221
	
	
	var $error = 0
	var $guess = ""
	var $last_guess = ""
	var $total_iterations = 0
	var $results_kept = 2
	
	; Initialize results
	if $results_history.size == 0
		$results_history.fill($results_kept, $guess_zero)
	
	
	var $test = $results_history.0
	$test.x += 1000
	
	
	; Skip optimization algo if last result error is low enough
	; Stops processing if vehicle is stopped
	if @trilat_calc_error($results_history.0) < 0.05
		$guess = $results_history.0
		$guess.iterations = $total_iterations
		return $guess
	
	
	
	; Set an initial guess value
	$guess = $guess_zero
	$guess.error = @trilat_calc_error($guess)

	
	; Try the guess provided, see if its better
	if $options.guess != ""
		$error = @trilat_calc_error($options.guess)
		if $guess.error > $error
			; replace the guess
			$guess = $options.guess
	
	
	
	; Try the last result
	; Stay still to get accurate fast
	$error = @trilat_calc_error($results_history.0)
	if $guess.error > $error
		; replace the guess
		$guess = $results_history.0
	
	
	
	; Try extrapolated future position based on results history
	; for accuracy of moving vehicles
	var $cur_pos = $results_history.0
	var $last_pos = $results_history.1
	
	var $future_pos = ""
	$future_pos.x = $cur_pos.x - $last_pos.x
	$future_pos.y = $cur_pos.y - $last_pos.y
	$future_pos.z = $cur_pos.z - $last_pos.z
	$future_pos.error = @trilat_calc_error($future_pos)
	if $future_pos.error < $guess.error
		$guess = $future_pos
	
	
	
	; Try each beacon to see if they are better as an initial guess
	foreach $trilat_beacons ($index, $beacon)
		$error = @trilat_calc_error($beacon.position)
	
		if $error < $guess.error
			$guess = $beacon.position
			$guess.error = $error
			
	
	
	; Make a second initial guess near the first guess
	; needed because the new weight calc is done from $last_guess vs this guess
	$last_guess = $guess
	
	$guess.x = $last_guess.x + 100000
	$guess.y = $last_guess.y + 100000
	$guess.z = $last_guess.z + 100000
	$guess.error = @trilat_calc_error($guess)
	
	
	

	
	; Set an initial best guess
	; gets set to the best initial position
	; Should fix random large error spikes when moving
	var $best_guess = $guess
	
	

	
	; Do the iterations
	var $weight = 0.1 ; changin this doesnt do much, gets updated every iteration
	var $i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		
		$guess = $last_guess
		$guess.x += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.x - $last_guess.x)))
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess

		$i++
	
	
	
	$guess = $best_guess
	$last_guess = $best_guess
	$last_guess.y += $weight
	$weight = 0.1
	$i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		$guess = $last_guess
		$guess.y += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.y - $last_guess.y)))
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess

		$i++
		
	
	
	
	
	$guess = $best_guess
	$last_guess = $best_guess
	$last_guess.z += $weight
	$weight = 0.1
	$i = 0
	while $i < $options.max_iterations
		$total_iterations += 1
		var $e = $guess.error
		$e.round()
		
		$guess = $last_guess
		$guess.z += $weight
		$guess.error = @trilat_calc_error($guess)
		
		$weight = $weight - ($options.learning_rate * ($guess.error / ($guess.z - $last_guess.z)))
		
		
		if ($guess.error < $best_guess.error)
			$best_guess = $guess
		$i++



	
	$best_guess.iterations = $total_iterations ; how many times we tried to optimize
	$results_history.insert(0, $best_guess) ; Insert new result into history
	$results_history.pop() ; Pop last value to avoid a massive history
	
	return $best_guess
