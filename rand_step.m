function y = rand_step(stim_len, samp_freq, amp)
    y=[];
    for i=1:stim_len
        y=[y repelem(datasample(0:amp+0.5,1).*rand(1),samp_freq)];   
    end
    y=smooth(y,round(1000/samp_freq*10));
end