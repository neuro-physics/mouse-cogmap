function p = sorw_GetSimulationParam(start_pos,L,A,shape,w,alpha,xi,nu,food_site,stopAtFood,delta_model,pmin,can_go_back)
%   .start_pos: 'N', 'S','W','E' -- starting position of mouse
%   .L: [width,height] of the arena
%   .A: adjacency matrix where each entry A(i,j) is the step probability between sites j->i (this is not a typo, step from element in column to element in row)
%   .shape: either 'square' or 'circle' (shape of the arena represented by A)
%   .w: number of memory steps
%   .alpha: memory reinforcement fraction
%   .xi: correlation length of the memory reinforcement
%   .nu: power law exponent of the pl decay
%   .food_site: index of the site in the arena that has food (must be in [1,size(A,1)] )
%   .stopAtFood: true or false; if true, each run stops once the mouse finds the food; otherwise, the mouse runs for tTotal time steps
%   .delta_model: 'pl', 'exp', or 'plexp' for power-law or exponential, por power-law-exponential (autocorrelation-like), respectively
%                 'exp': Delta(t) = alpha*exp(-t/xi)
%                 'pl' : Delta(t) = alpha/(t+1)^nu
%                 'plexp': Delta(t) = alpha*exp(-t/xi)/(t+1)^nu
%   .pmin: minimum step probability (avoids deleting edges from the lattice graph); if pmin == 0, then the learning may delete edges (i.e., some steps will be impossible, causing the code to get stuck)
%   .can_go_back: if false, then the mouse can never move to the adjacent square from where it immediately came in the current time step
    p = struct('start_pos',start_pos,...
               'L',L,'A',A,'shape',shape,...
               'delta_model',delta_model,...
               'w',w,'alpha',alpha,'xi',xi,'nu',nu,...
               'food_site',food_site,'stopAtFood',stopAtFood,...
               'pmin',pmin,...
               'can_go_back',can_go_back);
end