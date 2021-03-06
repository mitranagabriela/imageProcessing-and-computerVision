function [MOVINGREG] = registerImages_RM(MOVING,FIXED)
%registerImages  Register grayscale images using auto-generated code from Registration Estimator app.
%  [MOVINGREG] = registerImages(MOVING,FIXED) Register grayscale images
%  MOVING and FIXED using auto-generated code from the Registration
%  Estimator app. The values for all registration parameters were set
%  interactively in the app and result in the registered image stored in the
%  structure array MOVINGREG.

% Auto-generated by registrationEstimator app on 17-Apr-2018
%-----------------------------------------------------------


% Feature-based techniques require license to Computer Vision System Toolbox
checkLicense()

% Convert RGB images to grayscale
FIXED = rgb2gray(FIXED);
MOVING = rgb2gray(MOVING);

% Default spatial referencing objects
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Detect MSER features
fixedPoints = detectMSERFeatures(FIXED,'ThresholdDelta',0.855556,'RegionAreaRange',[10 27757],'MaxAreaVariation',0.984375);
movingPoints = detectMSERFeatures(MOVING,'ThresholdDelta',0.855556,'RegionAreaRange',[10 27757],'MaxAreaVariation',0.984375);

% Extract features
[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,'Upright',false);
[movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints,'Upright',false);

% Match features
indexPairs = matchFeatures(fixedFeatures,movingFeatures,'MatchThreshold',49.652778,'MaxRatio',0.496528);
fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));
movingMatchedPoints = movingValidPoints(indexPairs(:,2));
MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;
MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;

% Visualize
figure; ax = axes;
showMatchedFeatures(MOVING,FIXED, movingMatchedPoints, fixedMatchedPoints,'montage','Parent',ax);
title(ax, 'Candidate point matches MR');
legend(ax, 'Matched points 1','Matched points 2');

% Apply transformation - Results may not be identical between runs because of the randomized nature of the algorithm
tform = estimateGeometricTransform(movingMatchedPoints,fixedMatchedPoints,'projective');
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);

% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;

end

function checkLicense()

% Check for license to Computer Vision System Toolbox
CVSTStatus = license('test','video_and_image_blockset');
if ~CVSTStatus
    error(message('images:imageRegistration:CVSTRequired'));
end

end