fileInput = 'JackieTrussDesign.mat';
[~, fileName, ~] = fileparts(fileInput);

load(fileName)

numMembers = size(C, 2); % number of members
numJoints = size(C, 1); % number of joints
numSupportForces = size(Sx, 2); % number of support forces

%% Constructing the e matrix
[joints, members] = find(C == 1); % row and column vector for every point with a 1 on C

% Construct the unit vector matrix with the right size
eRows = numJoints * 2;
eCols = numMembers + numSupportForces;
e = zeros(eRows, eCols);

% storage for the member length -- filled in by the for loop 
% later used for max load calculations
memLength = zeros(numMembers, 1);

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
    memLength(i) = distance; 

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
F = e \ (L);

%% Calculating the maximum theoretical load
% buckling curve for the acrylic (provided in the manual)
Cfit = 3391.3; alpha = 2.012; Ufit = 1.52;

W = sum(abs(L)); % applied test load as a magnitude -- not really need for
                 % something that is just one applied load but this extends
                 % the usage cases of our computational model
R = F(1:numMembers) / W; % calculates the ratio of internal force to 
                         % applied load for every member
Fb = Cfit * memLength.^(-alpha); % creates a vector with all buckling forces

% Ideally, tension members never fail relative to compression members, so 
% we set the buckling force of those to infinity in the computation
Wfail = inf(numMembers, 1); 
comp = R < 0; % gets the indices of the compression members
Wfail(comp) = Fb(comp) ./ (-R(comp)); % calculates the failure force for each member

[Wmax, crit] = min(Wfail); % gets the critical failure force and critical member
W_uncertainty = Ufit / abs(R(crit));

%% Save and Write to output
%save('TrussDesign1_JackiePeggyZhixin_A3.mat','C','Sx','Sy','X','Y','L');
fileOutput = [fileName '.txt'];
fileID = fopen(fileOutput, 'w');

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

% member forces
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
%totalLen = totalLen*39.3701; % inches to meters
cost = sum(memLength)+10*numJoints;
cost = round(cost, 3, "significant");
costline = ['Cost of truss: $', num2str(cost), '\n'];
fprintf(fileID, costline);


mlcr = Wmax/cost;
mlcr = round(mlcr, 3, "significant");
mlcrLine = ['Theoretical max load/cost ratio in oz/$: ', num2str(mlcr), '\n'];
fprintf(fileID, mlcrLine);