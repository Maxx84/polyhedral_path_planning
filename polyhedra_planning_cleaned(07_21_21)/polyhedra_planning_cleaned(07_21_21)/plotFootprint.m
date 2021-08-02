function [outPgons] = plotFootprint(inCurrentCentroid, inAdjacentCentroidXY,inSideLength,inNumSides, inAngle, inColor_str, inCenterFaceNumber,inPrintAdjacent,inTheta,inFaceNumbers)

%This function plots the polygons associated with the next downface to
%create a visual representation of a "footprint" on the graph

%correct for the default orientation in the 'nsidedpoly' function
if inNumSides(1) == 5
    polyFuncCorrection1 = 90;
    polyFuncCorrection2 = 90;
elseif inNumSides(1) == 3
    polyFuncCorrection1 = -30;
    % Changed from +30 to -30 for icosahedron
    polyFuncCorrection2 = -30;
else
    polyFuncCorrection1 = 180;
    polyFuncCorrection2 = 180;
end

% create polygons appropriately oriented around each of the centroids
pgon1 = nsidedpoly(inNumSides(1), 'SideLength', inSideLength, 'Center', [inCurrentCentroid(1), inCurrentCentroid(2)] ); % pgon1 is the polygon which is at the center of the footprint each time.
pgon1 = rotate(pgon1,inAngle+polyFuncCorrection1,[inCurrentCentroid(1), inCurrentCentroid(2)]);
b = text(inCurrentCentroid(1),inCurrentCentroid(2),num2str(inCenterFaceNumber), 'FontSize',20); % label this center polygon with its appropriate face number
%uistack(b, 'top')
plot(pgon1, 'FaceColor', inColor_str);

% now plot the centroids
for i = 1:inNumSides(1)
    %plot(inAdjacentCentroidXY(i,1), inAdjacentCentroidXY(i,2), 'b*');
    outPgons(i) = nsidedpoly(inNumSides(i+1),'SideLength', inSideLength, 'Center', [inAdjacentCentroidXY(i,1), inAdjacentCentroidXY(i,2)]); % use calculated adjacent centorids to draw next polygons
    outPgons(i) = rotate(outPgons(i),inAngle+inTheta*i-polyFuncCorrection2,[inAdjacentCentroidXY(i,1), inAdjacentCentroidXY(i,2)]);  % rotate the polygon appropriately with respsect to its centroid
    if inPrintAdjacent
        c = text(inAdjacentCentroidXY(i,1),inAdjacentCentroidXY(i,2),num2str(inFaceNumbers(i)), 'FontSize',20); % label this center polygon with its appropriate face number
        uistack(c, 'top')
    end
    plot(outPgons(i), 'FaceColor', inColor_str, 'FaceAlpha', 0.1);
end

axis equal

end