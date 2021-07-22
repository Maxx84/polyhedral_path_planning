The main script to run is MAIN_Universal.m

% >>> The code calculates an A* path oblivious to the geometric constraints 
% of polyhedra using code adapted from "Interactive A* search demo
% 04-26-2005, Copyright 2009-2010 The MathWorks, Inc."
% After an A* path is generated, moves are considered that roll along and
% try to adhere to this optimal A* path, with geometric constraints. 
% The code proceeds to calculate the footprint of the polyhedra, i.e. the
% current downface and 2D net of possible next rolls as it 
% rolls along, considering the presence of obstacles, and tries to get it
% within a specified distance to the goal point by connecting together
% the footprints as it goes.

% >>> Note actual convergence on the goal point can
% be impossible; it depends on the placement of the point and the user's
% selected side length for the shape, etc. You define side length in the
% main while loop condition: 6 < dist_to_goal.
% There are problems with this naiive implementation of path planning;
% it looks only 1 step ahead each time. It can get stuck in cycles, and the
% path it generates can be far from optimal. If you have such problems, try
% tuning the sideLength, tolerance, and pathSegments variables below. 
% Even small changes can impact convergence. 

% From "Robert Baines, Joran Booth, and Rebecca Kramer-Bottiglio, Soft
% rolling membrane-driven tensegrity robots. RAL. 2020" 
% https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9162439