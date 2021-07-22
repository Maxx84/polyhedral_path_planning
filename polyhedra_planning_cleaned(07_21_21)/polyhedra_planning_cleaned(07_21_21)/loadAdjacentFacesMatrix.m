function [outAdjacentFaces] = loadAdjacentFacesMatrix(inPolyhedra)
%Lookup tables that define the physical arrangement of faces on the solid
%To create a new matrix:
%   1) Choose a solid and number every face
%   2) Starting with face 1, 2, 3, etc. define the adjacent faces
%       a) The lowest number adjacent face always goes first
%       b) Subsequent faces are counterclockwise from the lowest face
%       c) If a face has fewer neighbors than others, put 'nan' in the
%       entry where there is not a face
%   3) Create a name for the solid and paste it into this file, update
%   documentation

if strcmp(inPolyhedra, 'rhomba') == 1
    outAdjacentFaces = [2 3 4 5; %1
            1 8 7 6;             %2
            1 6 19 26;            %3
            1 26 23 13;          %4
            1 13 9 8;           %5
            2 18 3 nan;          %6
            2 10 16 18 ;         %7
            2 5 10 nan;          %8
            5 12 11 10;          %9
            7 8 9 15;            %10
            9 14 21 15;          %11
            9 13 23 14;         %12
            4 12 5 nan ;         %13
            11 12 22 nan ;       %14
            10 11 16 nan ;       %15
            7 15 21 17 ;         %16
            16 20 18 nan;        %17
            6 7 17 19 ;          %18
            3 18 20 24;          %19
            17 21 25 19;         %20
            11 22 20 16 ;        %21
            14 23 25 21;         %22
            4 24 22 12;          %23
            19 25 23 26 ;        %24
            20 22 24 nan;        %25
            3 24 4 nan];         %26
    
elseif strcmp(inPolyhedra, 'dodecahedron')
    outAdjacentFaces = [2 3 4 5 6; %1
        1 6 7 11 3;             %2
        1 2 11 10 4;            %3
        1 3 10 9 5;             %4
        1 4 9 8 6;              %5
        1 5 8 7 2;              %6
        2 6 8 12 11;            %7
        5 9 12 7 6;             %8
        4 10 12 8 5;            %9
        3 11 12 9 4;            %10
        2 7 12 10 3;            %11
        7 8 9 10 11];           %12

elseif strcmp(inPolyhedra, 'cube') % it's cube
    outAdjacentFaces = [2 3 4 5;   %1
                     1 5 6 3;   %2
                     1 2 6 4;   %3
                     1 3 6 5;   %4
                     1 4 6 2;   %5
                     2 5 4 3];  %6
else
    disp('error');
end
end

