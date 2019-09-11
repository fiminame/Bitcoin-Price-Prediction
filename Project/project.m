%clear all before execute the program
clear all
close all
clc

%Remove previous checkpoint
cd checkpoint
delete *.mat
cd ..

%Import the second colum of each data file
%And then change to transpose matrix
price=getdata('data/market-price.csv').';
a(1,:)=getdata('data/avg-block-size.csv').';
a(2,:)=getdata('data/cost-per-transaction.csv').';
a(3,:)=getdata('data/estimated-transaction-volume.csv').';
a(4,:)=getdata('data/hash-rate.csv').';
a(5,:)=getdata('data/market-cap.csv').';
a(6,:)=getdata('data/n-transactions.csv').';
a(7,:)=getdata('data/n-unique-addresses.csv').';
a(8,:)=getdata('data/output-volume.csv').';
a(9,:)=getdata('data/total-bitcoins.csv').';
a(10,:)=getdata('data/transaction-fees.csv').';


%Divide the data into 3 parts
%Divide the ratio by 0.8 for training, 0.1 for validation and 0.1 for testing
numTimeStepsTrain=floor(0.9*length(price));
numTimeStepsValidation=floor(0.05*length(price));
numTimeStepsTest=length(price)-numTimeStepsTrain-numTimeStepsValidation;

%This variable is sum of Data of Training and Data of Validation
%We make this just for comfort
untilValidation=numTimeStepsTrain+numTimeStepsValidation;

%Combine what is all in a different matrix into one matrix
data=[price;a];
dataTrain=data(:,1:numTimeStepsTrain);
dataValidation=data(:,numTimeStepsTrain+1:untilValidation);
dataTest=data(:,untilValidation+1:end);

%For each item of train data, calculate the average and standard deviation
%And then normalize Train data, Validaition data and Test data.
for i = 1 : 11
    mu(i)=mean(dataTrain(i,:));
    sig(i)=std(dataTrain(i,:));
    dataTrainStandardized(i,:)=(dataTrain(i,:)-mu(i))/sig(i);
    dataValidationStandardized(i,:)=(dataValidation(i,:)-mu(i))/sig(i);
    dataTestStandardized(i,:)=(dataTest(i,:)-mu(i))/sig(i);
end

%To train RNN model, make input value and target value
XTrain=dataTrainStandardized(:,1:end-1);
YTrain=dataTrainStandardized(1,2:end);

XValid = dataValidationStandardized(:,1:end-1);
YValid = dataValidationStandardized(1,2:end);

XTest = dataTestStandardized(:,1:end-1);
YTest = dataTest(1,1:end-1);

%The input property consists of 11 values
%Output value is only price
%the number of Hidden node is 500
numFeatures = 11;
numResponses = 1;
numHiddenUnits1 = 500;

%RNN model consists of inputlayer, LSTM, dropout, fullyConnected layer
layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits1)
    dropoutLayer(0.5)
    fullyConnectedLayer(numResponses)
    regressionLayer];

%We make checkpoint to check RMSE of validation data
checkpointPath = 'checkpoint';

%This number refers to the number of model learned.
EpochsNum = 500;
%This is hyper-parameters.
options = trainingOptions('sgdm',...
    'MaxEpochs',EpochsNum, ...
    'GradientThreshold',1,...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',100, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'ValidationData',{XValid,YValid}, ...
    'ValidationFrequency',10, ...
    'ValidationPatience',5, ... 
    'Plots','training-progress', ...
    'CheckpointPath',checkpointPath);

%Train RNN model.
net = trainNetwork(XTrain,YTrain,layers,options);

%Checking validation RMSE
listing=dir('checkpoint');
for i= 1 : EpochsNum
    %To see RMSE of validation data, we load checkpoint for every 10 learning.
   if mod(i,10) == 0
       for j= 3 : length(listing)
           %Find same file name as number of epochs
          if strcmp(extractBefore(extractAfter(listing(j).name,'checkpoint__'),'__2019'),num2str(i)) == 1
              %load the checkpoint
              load(strcat(pwd,'/checkpoint/',listing(j).name));
              %Predict YValid values with XValid values and loaded model              
              YValid_Pred=predict(net,XValid); 
              
              %Unnormalize the YValid predicted value
              YValid_Pred = sig(1)*YValid_Pred + mu(1);
              
              %Calculate RMSE between YValid Prediction and Validation data
              rmse=sqrt(mean(YValid_Pred-YValid).^2);
              fprintf('Epochs %d RMSE : %f\n',i,rmse);
          end
       end
   end
end

%load the last model to predict by Test data
%This is the same method for loading a model when checking RMSE of validation data
for j= 3 : length(listing)
    if extractBefore(extractAfter(listing(j).name,'checkpoint__'),'__2019') == EpochsNum
        load(strcat(pwd,'/checkpoint/',listing().name));
        break;
    end
end

%Predict Y of Train data
YTrain_Pred = predict(net,XTrain);
YTrain_Pred = sig(1)*YTrain_Pred + mu(1);

%Predict Y of Test data
YTest_Pred = predict(net,XTest);
YTest_Pred = sig(1)*YTest_Pred + mu(1);

%Calculate RMSE between YPred and Real Test data
rmse=sqrt(mean(YTest_Pred-YTest).^2);
fprintf('Final RMSE : %f\n',rmse);

%Plot all value of price
%including Train data, Validation data, Test data
%Predicted Train data, Predicted Validation data and Predicted Test data.
figure
hold on
%Train data
idx_train=1:numTimeStepsTrain;
plot(idx_train,dataTrain(1,1:end))
%Validation data
idx_val=numTimeStepsTrain:(numTimeStepsTrain+numTimeStepsValidation)-1;
plot(idx_val,dataValidation(1,1:end))
%Test data
idx_test=(numTimeStepsTrain+numTimeStepsValidation):length(price)-1;
plot(idx_test,dataTest(1,1:end))
%Predicted Train data
plot(idx_train(2:end),YTrain_Pred)
%Predicted Validation data
plot(idx_val(2:end),YValid_Pred)
%Predicted Test data
plot(idx_test(2:end),YTest_Pred)
hold off
xlabel("Time")
ylabel("Price")
title("Forecast")
legend(["TrainData" "ValidationData" "TestData" "Forecast-Train" "Forecast-Validation" "Forecast-Test"])

%Plot only for Test data
figure
subplot(2,1,1)
plot(YTest)
hold on
plot(YTest_Pred,'.-')
hold off
legend(["Observed" "Predicted"])
ylabel("Cases")
title("Forecast with Updates")

%Plot the value of RMSE
subplot(2,1,2)
stem(YTest_Pred - YTest)
xlabel("Month")
ylabel("Error")
title("RMSE = " + rmse)









