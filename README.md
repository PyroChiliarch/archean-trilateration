# archean-trilateration

## Find your location!


First place each of your 4 beacons with a computer running beacon.main.sc
Follow the instructions in calculate_beacon_pos.main.xc to get the position of each of your beacons
Each beacon needs to transmit their position, make sure you update beacon.main.sc

If you want to add additional beacons you can, just follow the last beacon setup again with the new distance values

Example Beacon:
 - Solar panel
 - Battery, computer running beacon.main.xc
 - Ground anchor to avoid movement
 - Antenna
![nsn_0](https://github.com/user-attachments/assets/b01c7e31-0a2e-4df8-9c7e-0b7af34e1905)

Once your beacons are setup, setup the receiver on you vehicle like this
![image](https://github.com/user-attachments/assets/ef551fd2-cf04-42bf-b94b-69aa08a22f3c)
You will need one receiver for beacon you have setup (you need at least 4)

once these are setup, you can copy the example.main.xc code and trilateration.xc file onto you computer

