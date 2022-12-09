% ux_set = 0:0.1:1;
% uy_set = 0:0.1:1;
% 
% ux_length = length(ux_set);
% uy_length = length(uy_set);

% total_length = ux_length * uy_length;
% 
% velocity_setting = zeros(total_length,2);
% 
% set_step = 1
% 
% for ux_step = 1:ux_length
%     for uy_step = 1:uy_length
%         velocity_setting(set_step,1) = ux_set(ux_step);
%         velocity_setting(set_step,2) = uy_set(uy_step);
%         set_step = set_step + 1;
%     end
% end

cOptDef = {   ...
    'rho',      1;
    'miu',      10e-4;
    'tol',      0.2;
    'solver',   '';
    'iplot',    1;
    'fid',      1 ;
    'width',     0.3;
    'height',    0.2;
    'n_x_cell', 300;
    'n_y_cell', 200;
    'n_cell',   100;
    'Ux_path',  '2D/data_10_cell_1000/Ux/';
    'Uy_path',   '2D/data_10_cell_1000/Uy/';
    'P_path',    '2D/data_10_cell_1000/Pressure/';
    'Boundary_path', '2D/data_10_cell_1000/Boundary/';
    'Grid_path','2D/data_10_cell_1000/Grid/',
    'Subd_path', '2D/data_10_cell_1000/Subd/'
    };

[got,opt] = parseopt(cOptDef);

step = 1;
num_step = 1;  % 저장파일 이름 맨 앞부분
% ux_setting = 1;
% uy_setting = 0;

rng(123);

for ux_setting=0.1:0.1:1.0   
    clf('reset')    
        for uy_setting=0.1:0.1:1.0
            for r=2:
        clearvars -except step max_step velocity_setting opt ux_setting uy_setting num_step
        ux_string_value = string(ux_setting);    
        uy_string_value = string(uy_setting);
            
        save_idx = strcat(int2str(num_step), "_ux_")
        save_s1 = strcat(save_idx, ux_string_value); % _ux_값
        save_s2 = strcat(save_s1, "_uy_"); % _uy_값
        save_s_total = strcat(save_s2, uy_string_value); % _ux_값_uy_값
    
        x_left_min = opt.width*0.50;
        x_left_max = opt.width*0.75;
        x_right_min = opt.width*0.76;
        x_right_max = opt.width*0.95;
        y_top_min = opt.height*0.5+opt.height*0.1;
        y_top_max = opt.height*0.95;
        y_bottom_min = opt.height*0.25;
        y_bottom_max = opt.height*0.5-opt.height*0.1;         
    
        x_left = (x_left_max - x_left_min)*rand(1, 1) + x_left_min;
        x_right = (x_right_max - x_right_min)*rand(1, 1) + x_right_min;
        y_top = (y_top_max - y_top_min)*rand(1, 1) + y_top_min;
        y_bottom = (y_bottom_max - y_bottom_min)*rand(1, 1) + y_bottom_min;
    
%         Geometry and mesh generation.
        fea.sdim = { 'x', 'y' };
        grid01 = rectgrid( opt.n_cell, opt.n_cell, [0 opt.width;0 opt.height] );
        indc01 = selcells( grid01, "(x>"+x_left+")&(x<"+x_right+")&(y>"+y_bottom+")&(y<"+y_top+")"); 
        grid01 = delcells( grid01, indc01 );

        fea.grid = grid01;
        
        fea.grid.b(3,fea.grid.b(3,:)==4) = -4;
        fea.grid.b(3,fea.grid.b(3,:)==3) = -3;
        fea.grid.b(3,fea.grid.b(3,:)==2) = -2;
        fea.grid.b(3,fea.grid.b(3,:)==1) = -1;
        fea.grid.b(3,fea.grid.b(3,:)==-4) = 1;
        fea.grid.b(3,fea.grid.b(3,:)==-2) = 3;
        fea.grid.b(3,fea.grid.b(3,:)==-1) = 4;
        fea.grid.b(3,fea.grid.b(3,:)==-3) = 2;    
        
        s1 = strcat(opt.Grid_path,int2str(i)); % Grid/0
        s2 = strcat(s1,save_s_total);
        s3 = strcat(s2,".jpg");
    
        plotgrid(fea.grid,...
                'boundary', 'off',...
                 'axis','off');
        image = gcf;
        exportgraphics(image,s3);

        clf('reset');
%       Problem definition
        fea = addphys( fea, @navierstokes ); % Navier-Stokes equations physics mode
    
%         Boundary Setting
%         e.g. ) fea.phys.ns.bdr.sel(boundary_number) = {1: Wall, 2: Inlet, 3: Neutral outflow, 4: Outflow, 5: Symmetry/splip}
        i_inflow = findbdr(fea, ['x<=', num2str(opt.width*0.1)]); % Inflow boundary number
        i_outflow = findbdr(fea, ['x>=', num2str(opt.width*0.99)]); % Outflow boundary number
    
        fea.phys.ns.bdr.sel(i_inflow) = 2;
        fea.phys.ns.bdr.sel(i_outflow) = 3;
    
        fea.phys.ns.dvar = { 'u', 'v', 'p' };
        fea.phys.ns.prop.turb.model = 'laminar';
    
        fea.phys.ns.bdr.coef{2, end}{1, i_inflow} = ux_setting;
        fea.phys.ns.bdr.coef{2, end}{2, i_inflow} = uy_setting;
    

%         ---------- Boundary ----------
%          Boundary 생성 및 저장 (200(세로) x 300(가로))
        Boundary = ones(opt.n_y_cell,opt.n_x_cell); % 200 x 300 배열생성
        Boundary(1:opt.n_y_cell , 1) = 3; % 입구(3)
        Boundary(1:opt.n_y_cell , opt.n_x_cell) = 4; % 출구(4)
        Boundary(1 , 2:opt.n_x_cell-1) = 2; % 벽(2) 위
        Boundary(opt.n_y_cell , 2:opt.n_x_cell-1) = 2; % 벽(2) 아래

        bdr_y_top = opt.n_y_cell - round(opt.n_y_cell * (y_top/opt.height))        
        bdr_y_bottom = opt.n_y_cell - round(opt.n_y_cell * (y_bottom/opt.height))
        bdr_x_left = round(opt.n_x_cell * (x_left/opt.width))
        bdr_x_right = round(opt.n_x_cell * (x_right/opt.width))
    
        Boundary(bdr_y_top:bdr_y_bottom,bdr_x_left:bdr_x_right) = 5;
        Boundary(bdr_y_top+1:bdr_y_bottom-1,bdr_x_left+1:bdr_x_right-1) = 0;
        Boundary;

        save('2D/data_10_cell_1000/Boundary/'+save_s_total+".mat",'Boundary');

        %%%% Solver Call
        fea = parsephys( fea );   % Check and parse physics modes.
        fea = parseprob( fea );
    
        fea.sol.u = solvestat( fea, ...
            'iupw', [ 0, 0, 0 ], ...
            'linsolv', 'backslash', ...
            'icub', 'auto', ...
            'nlrlx', 1, ...
            'toldef', 1e-06, ...
            'tolchg', 1e-06, ...
            'reldef', 0, ...
            'relchg', 1, ...
            'maxnit', 20, ...
            'nproc', 4, ...
            'init', { 'u0_ns', 'v0_ns', 'p0_ns' }, ...
            'solcomp', [ 1; 1; 1 ] );
    
%         파일 저장
        columns = {'x', 'y', 'ux', 'uy', 'p'};
        temp = reshape(fea.sol.u, [], 3);
        temp = [fea.grid.p' temp]
    
        output = array2table(temp, 'VariableNames', columns);
        
        filename = '2D/data_10_cell_1000/Solve/'+save_s_total+'.csv';
        writetable(output,filename,'Delimiter', ',','QuoteStrings',true);
        
        num_step = num_step +1;
        end    
end
% % while step<max_step
% while (ux_setting<11)&&(uy_setting<11)    
%     for i = 1:10 % 1set(ux, uy)에 대하여 sample 10개 생성
%         clf('reset')
%         clearvars -except step max_step velocity_setting opt ux_setting uy_setting num_step
% 
%         ux_string_value = string(ux_setting);
%         uy_string_value = string(uy_setting);
%             
%         save_idx = strcat(int2str(num_step), "_ux_")
%         save_s1 = strcat(save_idx, ux_string_value); % _ux_값
%         save_s2 = strcat(save_s1, "_uy_"); % _uy_값
%         save_s_total = strcat(save_s2, uy_string_value); % _ux_값_uy_값
%     
%         x_left_min = opt.width*0.50;
%         x_left_max = opt.width*0.75;
%         x_right_min = opt.width*0.76;
%         x_right_max = opt.width*0.95;
%         y_top_min = opt.height*0.5+opt.height*0.1;
%         y_top_max = opt.height*0.95;
%         y_bottom_min = opt.height*0.25;
%         y_bottom_max = opt.height*0.5-opt.height*0.1;         
%     
%         x_left = (x_left_max - x_left_min)*rand(1, 1) + x_left_min;
%         x_right = (x_right_max - x_right_min)*rand(1, 1) + x_right_min;
%         y_top = (y_top_max - y_top_min)*rand(1, 1) + y_top_min;
%         y_bottom = (y_bottom_max - y_bottom_min)*rand(1, 1) + y_bottom_min;
%     
% %         Geometry and mesh generation.
%         fea.sdim = { 'x', 'y' };
%         grid01 = rectgrid( opt.n_cell, opt.n_cell, [0 opt.width;0 opt.height] );
% %         grid01 = rectgrid(opt.n_x_cell, opt.n_y_cell, [0 opt.width;0 opt.height]);
% %         arr_grid = ones(1, size(grid01.p, 2))        
% %         disp(size(grid01.p));
%         indc01 = selcells( grid01, "(x>"+x_left+")&(x<"+x_right+")&(y>"+y_bottom+")&(y<"+y_top+")"); 
% %         for i = 1:size(indc01,2)
% %             arr_grid(:, indc01(1, i)) = 5;
% %         end
% %         disp(size(arr_grid));
% %         disp(size(indc01));
%         grid01 = delcells( grid01, indc01 );
% %         disp(size(grid01.p));
%         fea.grid = grid01;
%         
% %         Re-generate Grid.
%         fea.grid.b(3,fea.grid.b(3,:)==4) = -4;
%         fea.grid.b(3,fea.grid.b(3,:)==3) = -3;
%         fea.grid.b(3,fea.grid.b(3,:)==2) = -2;
%         fea.grid.b(3,fea.grid.b(3,:)==1) = -1;
%         fea.grid.b(3,fea.grid.b(3,:)==-4) = 1;
%         fea.grid.b(3,fea.grid.b(3,:)==-2) = 3;
%         fea.grid.b(3,fea.grid.b(3,:)==-1) = 4;
%         fea.grid.b(3,fea.grid.b(3,:)==-3) = 2;    
%         
%         s1 = strcat(opt.Grid_path,int2str(i)); % Grid/0
%         s2 = strcat(s1,save_s_total);
%         s3 = strcat(s2,".jpg");
%     
%         plotgrid(fea.grid,...
%                 'boundary', 'off',...
%                  'axis','off');
%         image = gcf;
%         exportgraphics(image,s3);
%     
%         clf('reset');
%         s1 = strcat(opt.Subd_path,int2str(i)); 
%         s2 = strcat(s1,save_s_total);
%         s3 = strcat(s2,".jpg");
%         plotsubd(fea,...
%                 'boundary', 'off',...
%                  'axis','off', ...
%                  'labels','off', ...
%                  'grid','off');
%         image = gcf;
%         exportgraphics(image,s3);
%     
%         clf('reset');
% %       Problem definition
%         fea = addphys( fea, @navierstokes ); % Navier-Stokes equations physics mode
%     
% %         Boundary Setting
% %         e.g. ) fea.phys.ns.bdr.sel(boundary_number) = {1: Wall, 2: Inlet, 3: Neutral outflow, 4: Outflow, 5: Symmetry/splip}
%         i_inflow = findbdr(fea, ['x<=', num2str(opt.width*0.1)]); % Inflow boundary number
%         i_outflow = findbdr(fea, ['x>=', num2str(opt.width*0.99)]); % Outflow boundary number
%     
%         fea.phys.ns.bdr.sel(i_inflow) = 2;
%         fea.phys.ns.bdr.sel(i_outflow) = 3;
%     
%         fea.phys.ns.dvar = { 'u', 'v', 'p' };
%         fea.phys.ns.prop.turb.model = 'laminar';
%     
%         fea.phys.ns.bdr.coef{2, end}{1, i_inflow} = ux_setting;
%         fea.phys.ns.bdr.coef{2, end}{2, i_inflow} = uy_setting;
%     
% 
% %         ---------- Boundary ----------
% %          Boundary 생성 및 저장 (200(세로) x 300(가로))
%         Boundary = ones(opt.n_y_cell,opt.n_x_cell); % 200 x 300 배열생성
%         Boundary(1:opt.n_y_cell , 1) = 3; % 입구(3)
%         Boundary(1:opt.n_y_cell , opt.n_x_cell) = 4; % 출구(4)
%         Boundary(1 , 2:opt.n_x_cell-1) = 2; % 벽(2) 위
%         Boundary(opt.n_y_cell , 2:opt.n_x_cell-1) = 2; % 벽(2) 아래
% 
%         bdr_y_top = opt.n_y_cell - round(opt.n_y_cell * (y_top/opt.height))        
%         bdr_y_bottom = opt.n_y_cell - round(opt.n_y_cell * (y_bottom/opt.height))
%         bdr_x_left = round(opt.n_x_cell * (x_left/opt.width))
%         bdr_x_right = round(opt.n_x_cell * (x_right/opt.width))
%     
%         Boundary(bdr_y_top:bdr_y_bottom,bdr_x_left:bdr_x_right) = 5;
%         Boundary(bdr_y_top+1:bdr_y_bottom-1,bdr_x_left+1:bdr_x_right-1) = 0;
%         Boundary;
% 
%         save('2D/data_10_cell_1000/Boundary/'+save_s_total+".mat",'Boundary');
% 
%         %%%% Solver Call
%         fea = parsephys( fea );   % Check and parse physics modes.
%         fea = parseprob( fea );
%     
%         fea.sol.u = solvestat( fea, ...
%             'iupw', [ 0, 0, 0 ], ...
%             'linsolv', 'backslash', ...
%             'icub', 'auto', ...
%             'nlrlx', 1, ...
%             'toldef', 1e-06, ...
%             'tolchg', 1e-06, ...
%             'reldef', 0, ...
%             'relchg', 1, ...
%             'maxnit', 20, ...
%             'nproc', 4, ...
%             'init', { 'u0_ns', 'v0_ns', 'p0_ns' }, ...
%             'solcomp', [ 1; 1; 1 ] );
%     
% %         파일 저장
%         columns = {'x', 'y', 'ux', 'uy', 'p'};
%         temp = reshape(fea.sol.u, [], 3);
%         temp = [fea.grid.p' temp]
%     
%         output = array2table(temp, 'VariableNames', columns);
%         
%         filename = '2D/data_10_cell_1000/solve/'+save_s_total+'.csv';
%         writetable(output,filename,'Delimiter', ',','QuoteStrings',true);
%         
%         num_step = num_step +1;
%     end
%     ux_setting = ux_setting+0.1;
%     uy_setting = uy_setting+0.1;
% end
