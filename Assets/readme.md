#lake fishing game plan
###requirements done:
* water caustics -> caustics under water in the lake
* water refraction -> water surface material
* log to file - logtofile.cs
* object pooling - game manager -> fish
* 2 try catch exception - object pooling, log to file

###game stuff done:
* fish movement
* rod movement
* scoring
* gui

###requirements todo:

###fishing rod mechanics:
rotate by z axis to dip or pull rod
button press space to pull

rotate by y to move position in where to fish in the lake
button input.horizontal

rotate by x to shake left right, maybe not needed
button enter?

move line forward back
rotate by z axis
pivot on the tip of rod
shift w s 

move the line left and right
rotate by x axis
shift a d 

gui score at the top screen

###fish mechanics:
fish 0 0 0 rotation face to the right.

float up down y axis
move  and rotate randomly after hitting the wall

gets caught by line like a magnet, on collision
