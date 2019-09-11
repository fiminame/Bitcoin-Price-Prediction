function marketprice = importfile(filename, dataLines)
%IMPORTFILE �ؽ�Ʈ ���Ͽ��� ������ ��������
%  MARKETPRICE = IMPORTFILE(FILENAME)�� ����Ʈ ���� ���׿� ���� �ؽ�Ʈ ���� FILENAME����
%  �����͸� �н��ϴ�.  ������ �����͸� ��ȯ�մϴ�.
%
%  MARKETPRICE = IMPORTFILE(FILE, DATALINES)�� �ؽ�Ʈ ���� FILENAME�� �����͸� ������
%  �� �������� �н��ϴ�. DATALINES�� ���� ���� ��Į��� �����ϰų� ���� ���� ��Į��� ������ Nx2 �迭(��������
%  ���� �� ������ ���)�� �����Ͻʽÿ�.
%
%  ��:
%  marketprice = importfile("C:\Users\jiws8\Desktop\���м���\����\project\data\market-price.csv", [1, Inf]);
%
%  READTABLE�� �����Ͻʽÿ�.
%
% MATLAB���� 2019-06-09 17:13:36�� �ڵ� ������

%% �Է� ó��

% dataLines�� �������� �ʴ� ��� ����Ʈ ���� �����Ͻʽÿ�.
if nargin < 2
    dataLines = [1, Inf];
end

%% �������� �ɼ� ����
opts = delimitedTextImportOptions("NumVariables", 2);

% ���� �� ���� ��ȣ ����
opts.DataLines = dataLines;
opts.Delimiter = ",";

% �� �̸��� ���� ����
opts.VariableNames = ["Var1", "Value"];
opts.SelectedVariableNames = "Value";
opts.VariableTypes = ["string", "double"];
opts = setvaropts(opts, 1, "WhitespaceRule", "preserve");
opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% ������ ��������
marketprice = readtable(filename, opts);

%% ��� �������� ��ȯ
marketprice = table2array(marketprice);
end