% This is code that should be integrated in GUI
function Resp = apply_stim(Stim, RF, samp_freq, add_area)

    % Create a class instance 
    disp('Generating afferent population')
    a = affpop_hand(RF.hand_area);
    
%     a = affpop_hand('hand'); % a better way but will increase
%     computation time significantly
    
    s = Stimulus(reshape(Stim,[],1),RF.center,samp_freq,RF.radius);

    % Calculate response
    disp('Applying stimulus')
    r = a.response(s);

    % binning
    bin_size=1/samp_freq;
    edges=0:bin_size:length(Stim)/samp_freq;

    % Accumulate spikes
    disp('Computing firing rate')
    Resp=struct('Spike_times', [], 'FR', []);
    Resp.Spike_times=[r.responses.spikes];
    Resp.FR=histcounts(Resp.Spike_times, edges); 
    Resp.num_aff = a.num;

    %Area Analysis 
    if add_area
        disp('Computing area')
        Resp.Area=[];
        len_bin_area = max(10, 1000/samp_freq);
        bin_area=round(samp_freq/1000*len_bin_area);
        
        spike_mat=[];
        for num_aff=1:length(r.responses)
            [n,bin]=histc(r.responses(num_aff).spikes,edges);
            spike_mat(num_aff,:)=n;
        end

        indxaffs=find(strcmp('SA1',r.affpop.class) | strcmp('RA',r.affpop.class));
        t_count=1;
        for t = 1:bin_area:size(spike_mat,2)-bin_area
            response_now=spike_mat(indxaffs,t:t+bin_area-1);
            indx_on=find(sum(response_now,2));
            if length(indx_on)>=3
                all_locs=r.affpop.location(indxaffs(indx_on),:);

                x1=all_locs(:,1);
                y1=all_locs(:,2);
                vi = convhull(x1,y1);
                poly_temp=polyarea(x1(vi),y1(vi));

            else
                poly_temp=0;

            end
            Resp.Area(t_count) = poly_temp;
            t_count=t_count+1;
        end 
        Resp.Area_upsample=repelem(Resp.Area, bin_area);
    end
end