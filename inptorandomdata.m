% 本文件用于将网格点及及单元序列生成每个参数的随机矩阵，
%一列对应一个参数的一次用的随机场
clc
clear
%% 参数设置
% 输入参数随机场的均值、变异系数、自相关距离
mu=[10; % E
    0.30 ;  %mu
    2.24 ;%c
    8 ]; %phi
sz = size(mu)
 cov=[0.3 0.2 0.33 0.30]';%均值及变异系数
dh=[10 ]; dv=[2]; %自相关距离
Nsim=500;%随机场数量
ACF=1;%自相关函数类型
%% 载入文件：节点和单元
node=importdata('node.txt');
elelist=readcell('elementlist.txt');%所有的单元序号及节点坐标
elenum=size(elelist(:,1),1);%单元序号
present02=importdata('elementlist.txt',',',elenum);

%% 计算单元中心坐标 
elementlist=[];%单元序号
for i=1:elenum 
    ele=str2num(present02{i,1});
    elementlist=[elementlist ; ele(1)];
    centre_coord_xy(i,1)=mean(node(ele(2:end),2));%x
    centre_coord_xy(i,2)=mean(node(ele(2:end),3));%y       
end
% save('elelist.txt','elelisttorandonfield','-ascii');%保存需要赋值的单元序号

%% 生成参数的随机矩阵 
%midpoint_RF(坐标，均值，变异系数,相关距离，随机场数目，自相关函数的类型)
field=midpoint_RF(centre_coord_xy, mu,cov,dh,dv,Nsim,ACF);

%% 随机场画图 patch函数
fieldn=4;%在Nsim个随机场中显示第field个随机场
for i=1:size(mu,2)
    figure(i)
    for j=1:elenum 
        ele=str2num(present02{j,1});
        x=node(ele(2:end),2);
        y=node(ele(2:end),3);
        fy=repmat(field(j,fieldn,i),size(x,1),1);
        patch(x,y,fy)
        hold on 
    end
         set(gca,'Visible','off'); 
        axis('equal')        
        shading('interp')
        colormap('jet')
            % 添加颜色条并设置范围
    colorbar;
    caxis([min(field(:)), max(field(:))]); % 设置颜色条的数值范围为 field 数据的最小值和最大值
    title(['力学参数 ', num2str(i), ' 随机场']);
end
%% 保存数据 
%保存随机场数据
for i=1:size(mu,1)
    name={'param',num2str(i),'.txt'};
    savedata=field(:,:,i);
    save([name{1} name{2} name{3}],'savedata','-ascii')
end




