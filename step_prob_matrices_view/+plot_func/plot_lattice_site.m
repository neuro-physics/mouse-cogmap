function lh = plot_lattice_site(ax,L,site_latt,varargin)
    [site_patch_x,site_patch_y] = import.sorw_get_lattice_square_for_linear_index(site_latt,L);
    [pad,varargin]              = func.getParamValue('Padding',varargin,true,zeros(1,2));
    lh                          = plot(ax,mean(minmax(site_patch_x))+pad(1),mean(minmax(site_patch_y))+pad(2),'sw');
    set(lh,varargin{:});
end