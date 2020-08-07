%% Compute and plot linear regression for all afferents vs position and velocity
%Lin_Train(Resp_train_us, Stim_train_ds, vars, 1);
function [params, param_names, Rsq, num_aff] = train_model(Resp, Stim, lag, model)

    num_aff = Resp.num_aff;

    if strcmp(model, 'Area')
        resample_rate = length(Resp.Area_upsample)/length(Resp.Area);
        Stim = matrix_resample(Stim, resample_rate);
    end
    
    pos=Stim; pos=pos(3:end);
    vel=diff(Stim); vel=vel(2:end); speed=abs(vel);
    acc=diff(Stim,2); 
    X_vars=[pos speed acc];
    
    X_lag=lagmatrix(X_vars, 0:lag);
    X=X_lag(lag+1:end,:); 
    
    var_names ={'pos', 'speed', 'acc'};
    model_var_names={};
    for i=0:lag
        for n=1:length(var_names)
            model_var_names=[model_var_names [var_names{n} '-' num2str(i)]];
        end
    end
    
    % train one of the models
    switch model
        case 'FR'
            Y=smooth(Resp.FR(lag+3:end)); 
            Mdl = fitlm(X, Y, 'VarNames', [model_var_names 'FR']);     
            params = Mdl.Coefficients.Estimate;
            param_names = ['Intercept' model_var_names];
            Rsq = Mdl.Rsquared.Ordinary;
            
        case 'Area'   
            Y=smooth(Resp.Area(lag+3:end)); 
            % train model
            options = optimset('Display','off');
            num_iter = 100;
            best = 1e10;
            for it = 1:num_iter
                X0=rand(size(X,2)+1+3,1);
                [tmp resnorm] = lsqcurvefit(@nonlin_mapping,X0,X,Y,[],[],options);
                if (resnorm < best)
                    params = tmp;
                    best = resnorm;
                end
            end
            
            param_names = ['Intercept' model_var_names 'b0' 'b1' 'b2'];
            estimate = nonlin_mapping(params,X);
            RSS=sum((estimate-Y).^2);
            TSS=sum((Y-mean(Y)).^2);
            Rsq=1-RSS/TSS;
    end    
end