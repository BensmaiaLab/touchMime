function output = matrix_resample(input, resample_rate)
    output=[];
    for j=1:size(input,2)
        for i=1:round(size(input,1)/resample_rate)
            output(i,j)=sum(input(1+resample_rate*(i-1):resample_rate*i,j));
        end
    end
end