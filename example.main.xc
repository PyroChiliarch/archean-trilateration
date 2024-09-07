include "trilateration.xc"

timer interval 0.5
	
	; Select channel on our beacons
	output_text("beacon_0", 2, "nsn_0")
	output_text("beacon_1", 2, "nsn_1")
	output_text("beacon_2", 2, "nsn_2")
	output_text("beacon_3", 2, "nsn_3")
	
	; Get Position Data from remote beacons
	var $beacon_0 = @get_beacon("beacon_0")
	var $beacon_1 = @get_beacon("beacon_1")
	var $beacon_2 = @get_beacon("beacon_2")
	var $beacon_3 = @get_beacon("beacon_3")

	; This is a global created in trilateration.xc
	; Used to pass in an array because you can't normally
	$trilat_beacons.clear()
	$trilat_beacons.append($beacon_0, $beacon_1, $beacon_2, $beacon_3)
	
	; Perform Trilateration
	var $trilat_result = @trilat_3d_basic(".max_iterations{50}.learning_rate{0.8}")
	
	; Print result
	print("Result: ", $trilat_result)
	print("Result: ", $trilat_result.error)
