function marketprice = importfile(filename, dataLines)
%IMPORTFILE 텍스트 파일에서 데이터 가져오기
%  MARKETPRICE = IMPORTFILE(FILENAME)은 디폴트 선택 사항에 따라 텍스트 파일 FILENAME에서
%  데이터를 읽습니다.  숫자형 데이터를 반환합니다.
%
%  MARKETPRICE = IMPORTFILE(FILE, DATALINES)는 텍스트 파일 FILENAME의 데이터를 지정된
%  행 간격으로 읽습니다. DATALINES를 양의 정수 스칼라로 지정하거나 양의 정수 스칼라로 구성된 Nx2 배열(인접하지
%  않은 행 간격인 경우)로 지정하십시오.
%
%  예:
%  marketprice = importfile("C:\Users\jiws8\Desktop\공학수학\과제\project\data\market-price.csv", [1, Inf]);
%
%  READTABLE도 참조하십시오.
%
% MATLAB에서 2019-06-09 17:13:36에 자동 생성됨

%% 입력 처리

% dataLines를 지정하지 않는 경우 디폴트 값을 정의하십시오.
if nargin < 2
    dataLines = [1, Inf];
end

%% 가져오기 옵션 설정
opts = delimitedTextImportOptions("NumVariables", 2);

% 범위 및 구분 기호 지정
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 열 이름과 유형 지정
opts.VariableNames = ["Var1", "Value"];
opts.SelectedVariableNames = "Value";
opts.VariableTypes = ["string", "double"];
opts = setvaropts(opts, 1, "WhitespaceRule", "preserve");
opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 데이터 가져오기
marketprice = readtable(filename, opts);

%% 출력 유형으로 변환
marketprice = table2array(marketprice);
end