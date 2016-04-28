function c = getElephantTrafficContribution(data, elephants)

sumData = sum(data{5});
sumElephants = sum(elephants{5});

c = sumElephants/sumData;

end