function [outputArg1,outputArg2] = filter_moveAvg(data, win)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

es=data;
for i=1+win:length(data)-win;
    es(i)=mean(data(i-win:i+win));
end
es(1)=mean(data(1:2));
es(length(es))=mean(data(length(data)-1:length(data)));
    
outputArg1 = es;
%outputArg2 = inputArg2;
end

