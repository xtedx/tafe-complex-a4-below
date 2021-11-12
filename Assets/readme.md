#lake fishing game plan
###requirements done:
* water caustics
* log to file

###game stuff done:
* fish movement

###requirements todo:
* water refraction/trans
* try catch exception
* object pooling -> fish

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