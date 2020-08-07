function [y, freq_vec, amp_vec] = pink_noise(num_sec, samp_freq, max_amp, freq_max, power)

N=num_sec*samp_freq;

if nargin<5
    power = 1/2;
end

if rem(N,2)
    M = N+1;
else
    M = N;
end

% generate white noise
x = randn(1, M);
x = x-mean(x);

% FFT
X = fft(x);

% prepare a vector for 1/f multiplication
NumUniquePts = M/2 + 1;

amp_vec=[];
freq_vec = samp_freq*(0:M/2)/M;
amp_vec(freq_vec<1)=1;
for f=sum(freq_vec<1)+1:M/2+1
    amp_vec(f)=1/((freq_vec(f))^(power));
end
amp_vec(freq_vec>freq_max)=0;
amp_vec=smooth(amp_vec)';

AS=2*abs(X(1:NumUniquePts))/M;
% AS_before = AS(1:10)

% multiplicate the left half of the spectrum so the power spectral density
% is proportional to the frequency by factor 1/f, i.e. the
% amplitudes are proportional to 1/sqrt(f)
X(2:NumUniquePts)=X(2:NumUniquePts).*amp_vec(2:end)./AS(2:end);
AS=2*abs(X(1:NumUniquePts))/M;

% prepare a right half of the spectrum - a copy of the left one,
% except the DC component and Nyquist frequency - they are unique
X(NumUniquePts+1:M) = real(X(M/2:-1:2)) -1i*imag(X(M/2:-1:2));

% IFFT
y = ifft(X);

% prepare output vector y
y = real(y(1, 1:N));

% normalize
y=y/(max(y)-min(y))*max_amp;
y=y'-min(y);

end