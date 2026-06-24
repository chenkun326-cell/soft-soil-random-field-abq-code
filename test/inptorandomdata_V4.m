% 本文件用于将网格点及及单元序列生成每个参数的随机矩阵，
%将inp文件中整个part赋值随机场，
clc
clear
close all

%% 参数设置
% 输入参数随机场的均值、变异系数、自相关距离
%每层土顶部均值，列数为分层数
mu=[10 ; % E
    0.3;  %mu
    2.24 ;%c
    8 ]; %phi


cov=[0.15 0.02 0.15 0.15 ]';%均值及变异系数
dh=[15.6  ]; dv=[0.603 ]; %自相关距离
Nsim=500;%随机场数量
ACF=3;%自相关函数类型
%% 节点集合和部件名
Jobname='Job-0.inp';%确定性模型inp
part='soil';%需要赋值随机场的part
Set=[];%需要赋值随机场的Set，属于part中一部分，可以是全部,如果是全部,Set=[]
numofele_type=2;% part内含有几种类型单元
[node,elemen_strat]=readnode(Jobname,part);%部件中所有节点,elemen_strat为单元起点的*行
[element]=readelement(Jobname,elemen_strat,numofele_type); %提取part的所有单元，及单元节点编号，cell类
[elelist]=readelementlist(Jobname,Set,element); %需要赋值随机场的单元
elelist=sort(elelist,'ascend');%升序排列
%% 计算单元中心坐标 
elementlist=[];%单元序号
b=[];
for i=1:size(element,1)
    
    % 处理逗号分隔符并转换为数值
    % element_line = strrep(element{i,1}, ',', ' ');
    a = str2num(element{i,1});
    if isempty(a)
        error('无法转换单元行: %s', element{i,1});
    end
    b(end+1,1) = a(1);
    %
end
for i=1:size(elelist,1)
    current_ele = elelist(i,1);
    idx = find(b == current_ele);
    if isempty(idx)
        error('单元编号 %d 在b中未找到', current_ele);
    end
    % 处理逗号分隔符并转换为数值
    % element_line = strrep(element{idx,1}, ',', ' ');
    a = str2num(element{i,1});
    if numel(a) < 2
        error('单元 %d 缺少节点数据', current_ele);
    end
    centre_coord_xy(i,1) = mean(node(a(2:end),2)); % x坐标
    centre_coord_xy(i,2) = mean(node(a(2:end),3)); % y坐标
end
clear a b
save('elelist.txt','elelist','-ascii');
fid = fopen('element.txt','w');
for i=1:size(element,1)
    fprintf(fid,'%s\n', strrep(element{i}, ',', ' ')); % 确保保存时格式正确
end
fclose(fid);
%% 生成参数的随机矩阵 
%midpoint_RF(坐标，均值，变异系数,相关距离，随机场数目，自相关函数的类型)
 field=midpoint_RF(centre_coord_xy, mu,cov,dh,dv,Nsim,ACF);

%% 随机场画图 patch函数
%这部分删掉了，直接去调用pathrandomfield画图就行

%% 保存数据 
%保存随机场数据
for i=1:size(mu,1)
    name={'param',num2str(i),'.txt'};
    savedata=field(:,:,i);
    save([name{1} name{2} name{3}],'savedata','-ascii')
end


%% 子函数
function [node,i]=readnode(Jobname,part) %提取part的node
    inpfile=importdata(Jobname,',',25000);
    [partnode_start,~]=find(ismember(inpfile,['*Part, name=' part])==1);
    node=[];
    for i=(2+partnode_start):size(inpfile,1) %如果是字符串，这里会跳出
        a=str2num(inpfile{i,1});
        if isempty(a)
            break
        end
        node=[node; str2num(inpfile{i,1})];
    end
end

function [element]=readelement(Jobname,elemen_strat,numofele_type) %提取part的所有单元及单元节点编号
    inpfile=importdata(Jobname,',',25000);
    element={};
    for j=1:numofele_type %如果有两种单元
        for i=(1+elemen_strat):size(inpfile,1) %如果是字符串，这里会跳出
            a=str2num(inpfile{i,1});
            if isempty(a)
                break
            end
            element=[element; inpfile{i,1}];
        end
        elemen_strat=i;
    end
end

function [elelist]=readelementlist(Jobname,Set,element) %提取需要赋值的单元编号
          elelist=[];  
    if isequal(Set,[])%part中所有单元都赋值随机场
        for i=1:size(element,1)
            a=str2num(element{i,1});
            elelist(end+1,1)=a(1);
        end
    else
        inpfile=importdata(Jobname,',',250000);

        [partelement_start,~]=find(ismember(inpfile,['*Elset, elset=' Set])==1);
        for i=(1+partelement_start):size(inpfile,1) %如果是字符串，这里会跳出
            a=str2num(inpfile{i,1});
            if isempty(a)
                break
            end
            elelist=[elelist  str2num(inpfile{i,1})];
        end
        elelist=elelist';
        elelist=sort(elelist);
    end
end

