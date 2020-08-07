function [FR] = predict_FR(param_file_path, Stim)
    load(param_file_path)
  
    pos=Stim; pos=pos(3:end);
    vel=diff(Stim); vel=vel(2:end); speed=abs(vel);
    acc=diff(Stim,2); 
    X_vars=[pos speed acc];
    
    X_lag=lagmatrix(X_vars, 0:num_lags);
    X=X_lag(num_lags+1:end,:); 
    X=[ones(size(X,1),1) X];
    
    FR = X*params/num_aff*samp_freq;
    FR(FR<0)=0;
   
end