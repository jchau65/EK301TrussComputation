load("LuluDesign1.mat")

numMembers = size(C, 2); % number of members
numJoints = size(C, 1); % number of joints
numSupportForces = size(Sx, 2); % number of support forces

%% Constructing the e matrix
[joints, members] = find(C == 1); % row and column vector for every point with a 1 on C

% Construct the unit vector matrix with the right size
eRows = numJoints * 2;
eCols = numMembers + numSupportForces;
e = zeros(eRows, eCols);

% Other vars for output
totalLen = 0.0;

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
    totalLen = totalLen+distance;

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

%% Save and Write to output
%save('TrussDesign1_JackiePeggyZhixin_A3.mat','C','Sx','Sy','X','Y','L');
fileID = fopen('LuluDeisgn1Results.txt', 'w');

fprintf(fileID, 'EK301, Section A3, Group 7: Jackie C., Peggy W., Zhixin J. 11/7/2026.\n');

% print loads =============================================================
Ls = L(L ~= 0);
loadLine = 'Load: ';
for i=1:length(Ls)
    if(i == 1)
        loadLine = [loadLine, num2str(Ls(i))];
    else
        loadLine = [loadLine, ', ', num2str(Ls(i))];
    end
end
fprintf(fileID, [loadLine, ' oz\n']);

% print forces ============================================================
fprintf(fileID, 'Member forces in oz\n');

Sxs = Sx(Sx ~= 0);
Sys = Sy(Sy ~= 0);
numFs = length(F)-length(Sxs)-length(Sys);

% memeber forces
for i = 1:numFs
    

    dir = '';
    if(F(i) < 0)
        dir = ' (C)';
    elseif(F(i) > 0)
        dir = ' (T)';
    end

    numprint = round(abs(F(i)), 10);
    numprint = round(numprint, 3, "significant");

    forceLine = ['m', num2str(i), ': ', num2str(numprint), dir, '\n'];
    fprintf(fileID, forceLine);
end

% reaction forces
fprintf(fileID, 'Reaction forces in oz\n');

start = numFs+1;
ending = length(Sxs)+numFs;

for i = start:ending
    numprint = round(abs(F(i)), 10);
    numprint = round(numprint, 3, "significant");
    sxprint = ['Sx', num2str(i-start+1), ': ', num2str(numprint), '\n'];
    fprintf(fileID, sxprint);
end

start = ending+1;
ending = length(F);
for i = start:ending
    numprint = round(abs(F(i)), 10);
    numprint = round(numprint, 3, "significant");
    syprint = ['Sy', num2str(i-start+1), ': ', num2str(abs(F(i))), '\n'];
    fprintf(fileID, syprint);
end

% print prices ============================================================
totalLen = totalLen*39.3701;
cost = totalLen+10*numJoints;
cost = round(cost, 3, "significant");
costline = ['Cost of truss: $', num2str(cost), '\n']
fprintf(fileID, costline);


mlcr = max(abs(L))/cost;
mlcr = round(mlcr, 3, "significant");
mlcrLine = ['Theoretical max load/cost ratio in m/$: ', num2str(mlcr), '\n'];
fprintf(fileID, mlcrLine);