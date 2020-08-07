function TouchMime

    % set up GUI
    fig.main=figure('position',[100 100 1200 700],'visible', 'on');
    % create title
    fig.text.maintitle=uicontrol(fig.main,'style','text','unit','norm','pos',[.3,.95,.38,.04],'String','Compute Coefficients for Biomimetic Model','FontSize', 16, 'FontWeight', 'bold');

    % pick model checkboxes
    fig.check.fr= uicontrol('Style','checkbox','String','Firing Rate','unit','norm','pos',[.6 .85 .15 .05],'FontSize', 10, 'Value', 1);
    fig.check.area = uicontrol('Style','checkbox','String','Area','unit','norm','pos',[.75 .85 .15 .05],'FontSize', 10, 'Value', 0);
    
    % plot figure 
    fig.axis= axes('parent',fig.main,'Position',[0.05 0.08 .5 .8]);
    [origin,theta,pxl_per_mm,s]=plot_hand(fig.axis);
    regnum=length(s);
    rot=[cos(theta) -sin(theta);sin(theta) cos(theta)];
   
    % set parameters
    fig.text.select_param=uicontrol(fig.main,'style','text','unit','norm','pos',[.6,.78,.15,.03],'String','Specify model parameters:','FontSize', 10, 'HorizontalAlignment', 'left','FontWeight', 'bold');
    
    fig.text.samp_rate=uicontrol(fig.main,'style','text','unit','norm','pos',[.6,.73,.15,.03],'String','Sampling Rate','FontSize', 10, 'HorizontalAlignment', 'left');
    fig.edit.samp_rate = uicontrol('Style','edit','unit','norm','pos',[.8,.73,.1,.03], 'String', '500'); 

    fig.text.num_lags=uicontrol(fig.main,'style','text','unit','norm','pos',[.6,.68,.15,.03],'String','Number of Lags','FontSize', 10, 'HorizontalAlignment', 'left');
    fig.edit.num_lags = uicontrol('Style','edit','unit','norm','pos',[.8,.68,.1,.03], 'String', '5'); 

    fig.text.contact_rad=uicontrol(fig.main,'style','text','unit','norm','pos',[.6,.63,.15,.03],'String','Contact Area Radius (mm)','FontSize', 10, 'HorizontalAlignment', 'left');
    fig.edit.contact_rad = uicontrol('Style','edit','unit','norm','pos',[.8,.63,.1,.03], 'String', '2'); 
    
    % pick contact point
    fig.but.pick_contact=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.6,.4,.20,.05],'String','Pick Contact Area','FontSize', 10, 'callback',@pick_contact, 'backg',[.85 .85 .85]);

    % Mannual or centered on subpart
    fig.gr.typ = uibuttongroup('pos',[.6 .48 .2 .1],'unit','norm');
    fig.radio.center= uicontrol('Style','radio','String','Centered on pad','parent', fig.gr.typ,'unit','norm','pos',[.05 .6 .9 .33],'FontSize', 10,'tag','1');
    fig.radio.manual = uicontrol('Style','radio','String','Pick center manually','parent', fig.gr.typ, 'unit','norm','pos',[.05 .15 .9 .33],'FontSize', 10, 'tag','2');

    % output button - compute coefficients
    fig.but.compute=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.65,.08,.25,.07],'String','Compute Coefficients','FontSize', 11,'callback',@compute_coef, 'backg',[.7 .7 .7], 'FontWeight', 'bold');


    % save model parameters
    currentFolder = pwd;
    fig.text.select_param=uicontrol(fig.main,'style','text','unit','norm','pos',[.6,.33,.15,.03],'String','Save model to:','FontSize', 10, 'HorizontalAlignment', 'left','FontWeight', 'bold');
    fig.edit.save_location = uicontrol('Style','edit','unit','norm','pos',[.7,.25,.25,.05], 'String', currentFolder, 'FontSize', 10); 
    fig.but.save_coefficients=uicontrol(fig.main,'style','pushbutton','unit','norm','pos',[.6,.25,.08,.05],'String','Browse', 'callback',@save_coeffcients, 'backg',[.85 .85 .85], 'FontSize', 10);
    

    set(fig.main,'WindowButtonMotionFcn',@update_coords)

    function update_coords(~,~)
        cp = fig.axis.CurrentPoint;
        if cp(1)>405
            title([])
        else
            cp = pixel2hand(cp(1,1:2));
            title(sprintf('x: %0.1f, y: %0.1f', cp(1,1), cp(1,2)))
        end
    end

   global r
   global pick_center
   h=[];
   
   function pick_contact(~,~)
        delete(h)
        sel = get(get(fig.gr.typ,'SelectedObject'),'tag');
        radii=str2double(get(fig.edit.contact_rad, 'String'))*10/pxl_per_mm;
        [pick_center,r]=get_point();
        if sel=='1'
            pick_center=s(r).Centroid;
        end
        h = viscircles(pick_center,radii,'color','r','LineWidth',1);
   end
   
    function [coord,region]=get_point()
        coord=ginput(1); in=zeros(regnum,1);
        for jj=1:regnum
            in(jj) = inpolygon(coord(1),coord(2),s(jj).Boundary(:,1),s(jj).Boundary(:,2));
        end
        
        region=find(in);
        if(isempty(region))
            add_log('Out of the hand');
            coord=[]; region=[];
        end
        if(length(region)>2)
            add_log('For any unknowm reason, two regions were selected. Please restart');
            coord=[]; region=[];
        end
    end

    function new_locs=change_coord_sys(locs)
        locs=bsxfun(@minus,locs,origin);
        locs=locs/pxl_per_mm;
        new_locs=locs*rot;
    end

    function save_coeffcients(~,~)
       [file, PathName] = uiputfile('.mat');
       set(fig.edit.save_location, 'String', PathName);
    end

    waitfor(fig.main)
    function compute_coef(~,~)
        % save directory
        save_dir = get(fig.edit.save_location, 'String');
        
        % which models to compute
        value_fr = get(fig.check.fr, 'Value');
        value_area = get(fig.check.area, 'Value');
        
        % user-defined parameters
        samp_freq = str2double(get(fig.edit.samp_rate, 'String'));
        num_lags =  str2double(get(fig.edit.num_lags, 'String')); 
        RF.center =  change_coord_sys(pick_center);
        RF.hand_area = strcat(s(r).Tags{1:2});
        RF.radius = str2double(get(fig.edit.contact_rad, 'String'));
        
        % warnings and errors
        % samp_freq
        if isnan(samp_freq)
            error('Specify sampling rate')
        elseif mod(samp_freq,1)~=0 || mod(samp_freq,2)~=0
            error('Sampling rate has to be an even integer!')
        elseif samp_freq < 200
            warning('Low resolution might affect model performance. Consider increasing sampling rate.')
        end
        
        % num_lags
        if isnan(num_lags)
            error('Specify number of lags')
        elseif mod(num_lags,1)~=0
            error('Number of lags has to be an integer.')
        elseif num_lags > 7
            warning('Two many model parameters might increase computation time and lead to overfitting. Consider decreasing the numbe rof lags.')
        end
        
        % radius
        if RF.radius>5
            warning('Contact area is too large and might exceed your chosen hand subpart. Consider decreasing the radius.')
        end
        
        % no directory error
        if isempty(save_dir)
            error('Save directory not specified.')
        end
        
        % built-in parameters
        stim_len = 50;
        amp = 3;
        freq = 5;
        Stim=[pink_noise(stim_len, samp_freq, amp, freq); ...
            rand_step(stim_len, samp_freq, amp)];

        Resp = apply_stim(Stim, RF ,samp_freq, value_area);
       
        date_ident=datestr(now, 'ddmmmyyyy_HHMM');
        % compute models and save coefficients
        if value_fr
            [params, param_names, Rsq, num_aff] = train_model(Resp, Stim, num_lags, 'FR');
            disp('"Firing Rate" model')
            disp(['Computed ' num2str(length(params)) ' coefficients with R^2 = ' num2str(Rsq)])
            disp(['Writing to ' save_dir])    
            save([save_dir '\results\' date_ident '_FR'], 'samp_freq', 'num_lags', 'RF', 'params', 'param_names', 'Rsq', 'num_aff') 
        end
        
        if value_area
            [params, param_names, Rsq] = train_model(Resp, Stim, num_lags, 'Area');
            disp('"Area" model')
            disp(['Computed ' num2str(length(params)) ' coefficients with R^2 = ' num2str(Rsq)])
            disp(['Writing to ' save_dir])  
            save([save_dir '\results\' date_ident '_Area'], 'samp_freq', 'num_lags', 'RF', 'params', 'param_names', 'Rsq') 
        end
        
        close(fig.main)
    end

end




