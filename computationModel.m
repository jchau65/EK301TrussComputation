load("PracticeProblem1.mat")

numMembers = size(C, 2); % number of members
numJoints = size(C, 1); % number of joints
numSupportForces = size(Sx, 2); % number of support forces

%% Constructing the e matrix
[joints, members] = find(C == 1); % row and column vector for every point with a 1 on C

% Construct the unit vector matrix with the right size
eRows = numJoints * 2;
eCols = numMembers + numSupportForces;
e = zeros(eRows, eCols);

% Iterate through the part of e without the support forces
for i = 1:numMembers
    % find all of the associated indices with member i
    jointIndices = find(members == i);

    % Define a jointA and jointB for easier readability
    jointA = joints(jointIndices(2));
    jointB = joints(jointIndices(1));

    % Define two points P1 and P2
    P1 = [X(jointA), Y(jointA)];
    P2 = [X(jointB), Y(jointB)];

    % calculate deltas
    deltaX = P1(1) - P2(1);
    deltaY = P1(2) - P2(2);

    % calculate a distance value using defined points P1 and P2
    distance = norm(P1 - P2);

    % put into e matrix
    e(jointB, i) = deltaX/distance;
    e(jointA, i) = -deltaX/distance;
    e(jointB + numJoints, i) = deltaY/distance;
    e(jointA + numJoints, i) = -deltaY/distance;
end

% Implement the Sx and Sy force matrix into the e matrix
e(1:numJoints, (numMembers + 1):(numMembers+numSupportForces)) = Sx;
e((numJoints+1):(numJoints*2), (numMembers + 1):(numMembers+numSupportForces)) = Sy;

%% Calculate the force
F = e \ (-L)