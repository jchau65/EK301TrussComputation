%% C - Connection matrix
%{
Indicating connections: The matrix has j rows and m columns, where the row
represents the joint number and the column represents the member number.

Example: indicating the connection of member 1 to joints 1 and 2 by placing
a 1 in column 1 of rows 1 and 2.

We will use the following convention for the joint number and and the 
member number:
 - Joint number: A = 1, B = 2, etc.
 - Member number: alphabetical order, i.e. for members AB, AC, AD, BC
    - AB = 1, AC = 2, AD = 3, BC = 4

For the practice problem, there are 8 joints and 13 members.
This makes the following designation:
    - AB = 1 (connected to joints 1 & 2)
    - AD = 2 (connected to joints 1 & 4)
    - BC = 3 (connected to joints 2 & 3)
    - BD = 4 (connected to joints 2 & 4)
    - CD = 5 (connected to joints 3 & 4)
    - CE = 6 (connected to joints 3 & 5)
    - DE = 7 (connected to joints 4 & 5)
    - DF = 8 (connected to joints 4 & 6)
    - EF = 9 (connected to joints 5 & 6)
    - EG = 10 (connected to joints 5 & 7)
    - FG = 11 (connected to joints 6 & 7)
    - FH = 12 (connected to joints 6 & 8)
    - GH = 13 (connected to joints 7 & 8)
%}
C = [1 1 0 0 0 0 0 0 0 0 0 0 0;
     1 0 1 1 0 0 0 0 0 0 0 0 0;
     0 0 1 0 1 1 0 0 0 0 0 0 0;
     0 1 0 1 1 0 1 1 0 0 0 0 0;
     0 0 0 0 0 1 1 0 1 1 0 0 0;
     0 0 0 0 0 0 0 1 1 0 1 1 0;
     0 0 0 0 0 0 0 0 0 1 1 0 1;
     0 0 0 0 0 0 0 0 0 0 0 1 1];

%% S_x & S_y - Support force matrix
%{
S_x and S_y are matrices with j rows and 3 columns, which are connection
matrices for the support forces along each axis. 

For the practice problem, we have three unknown reactions (one pin and one
roller joint).

In each matrix, for each unknown reaction force, we put a 1 in the column
that corresponds to the joint j. 

For the practice problem, A has a pin (Sx1 and Sy1) and H has a roller
(Sy2).
%}
Sx = [1 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0];

Sy = [0 1 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 0;
      0 0 1];

%% X and Y joints
%{
These are two location vectors that let us input where each joint is
relative to a reference point.

X = [x1, x2...] -> xn is joint n's X distance from the reference frame
Y = [y1, y2...] => yn is joint n's Y distance from the reference frame

For the practice problem, we are going to choose A as the reference
point/frame, that way there are no negatives in either the X or Y
direction.
%}
X = [0 0 4 4 8 8 12 12];
Y = [0 4 8 4 8 4 4 0];

%% L - Load vector
%{
This vector has 2j elements; the first j elements correspond to loads in
the x direction for each of the j joints, and the last j elements represent
loads along the y direction.

For the practice problem, there is only a -25N vertical force on the joint
D.
%}
L = [0 0 0 0 0 0 0 0 0 0 0 -25 0 0 0 0];

%% Save the file to a .mat binary file
% change name as needed
save('PracticeProblem1.mat', 'C', 'Sx', 'Sy', 'X', 'Y', 'L')