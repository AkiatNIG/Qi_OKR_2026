function [outputArg1,outputArg2] = untitled(tmps, tax, data0)
%tmps: data for templates
%tax: time points
%data0: data for eye positions
%
%For demonstration, save all the files in a Matlab path. And run in the
%Command Window: "okr_detect(tmps,tax,data0)"
%
%Outputs: detected events (figures) and the frequency

%
close all;
%
%10 min (60s*10=600s), 72000pts ->6s/720pts = 0.0083s/pts = 120Hz 
%
%
th_gain=2;
for reps=1:2;
    tax=tax;
    org0=data0(:,reps);
    %
    nanP=isnan(org0);
    if sum(nanP)~=0;
        ppid=find(nanP==0);
        mm99bb=mean(org0(ppid));
        org0(nanP)=mm99bb;
    end
    %
    org0=org0-mean(org0);
    %t_smp=600/length(org0(:,1));%10hz
    t_smp=1/10;
    %
    dif0=[0;org0(1:length(org0)-1)-org0(2:length(org0))];
    %
    ths=mean(dif0)+std(dif0)*th_gain;
    fid=find(abs(dif0)>ths);
    gwin=[100,length(org0)-100];
    fid(fid<=gwin(1))=0;
    fid(fid>=gwin(2))=0;
    %
    fid_d=fid(1:length(fid)-1)-fid(2:length(fid));
    rems=find(fid_d>=-3);
    fid(rems)=0;
    %
    %%
    fid=fid(fid~=0);
    %
    figure('position',[150,400,760,380]);
    subplot(2,1,1);
    plot(tax,org0,'-k');hold on
    plot(tax,dif0);
    plot(tax(fid),dif0(fid),'o');
    set(gca,'box','off');
    set(gca,'tickdir','out');
    tit=title(['direc#',num2str(reps)]);
    set(tit,'fontsize',8);
    %
    %%
    wvs=cell(1,1);
    twin=[25,30];
    for i=1:length(fid);
        wv0=org0(fid(i)-twin(1):fid(i)+twin(2));
        wv0=wv0-mean(wv0(1:10));
        [val,mxid]=max(abs(wv0));
        fgf=fid(i)-twin(1)+mxid-1;
        wv0=org0(fgf-twin(1):fgf+twin(2));
        tx0=tax(fgf-twin(1):fgf+twin(2));
        %
        wv0b=filter_moveAvg(wv0,1);
        [val,mxid2]=max(abs(wv0b));
        fgf2=tx0(1)+mxid2-1;
        wv99=org0(fgf2-twin(1):fgf2+twin(2));
        tx99=tax(fgf2-twin(1):fgf2+twin(2));
        %
        wvs{i,1}=i;
        wvs{i,2}=tx0;
        wvs{i,3}=wv0;
        wvs{i,4}=fgf;
        wvs{i,14}=tx99;
        wvs{i,15}=wv99;
        wvs{i,16}=fgf2;
        %
        if dif0(fid(i))<0;
            wvs{i,5}=-1;
        elseif dif0(fid(i))>0;
            wvs{i,5}=1;
        end
    end
    %
    if isempty(wvs{1,1})==1;
        fid=500;
        for i=1:length(fid);
            wv0=org0(fid(i)-twin(1):fid(i)+twin(2));
            wv0=wv0-mean(wv0(1:10));
            [val,mxid]=max(abs(wv0));
            fgf=fid(i)-twin(1)+mxid-1;
            wv0=org0(fgf-twin(1):fgf+twin(2));
            tx0=tax(fgf-twin(1):fgf+twin(2));
            %
            wv0b=filter_moveAvg(wv0,1);
            [val,mxid2]=max(abs(wv0b));
            fgf2=tx0(1)+mxid2-1;
            wv99=org0(fgf2-twin(1):fgf2+twin(2));
            tx99=tax(fgf2-twin(1):fgf2+twin(2));
            %
            wvs{i,1}=i;
            wvs{i,2}=tx0;
            wvs{i,3}=wv0;
            wvs{i,4}=fgf;
            wvs{i,14}=tx99;
            wvs{i,15}=wv99;
            wvs{i,16}=fgf2;
            %
            if dif0(fid(i))<0;
                wvs{i,5}=-1;
            elseif dif0(fid(i))>0;
                wvs{i,5}=1;
            end
        end
    end
    %
    for i=2:length(wvs(:,1));
        if wvs{i,4}-wvs{i-1,4}<10;
            wvs{i-1,1}=99;
        end
    end
    %
    th_vamp=3;%10
    disp(size(wvs));
    for i=1:length(wvs(:,1));
        ewv=wvs{i,15};%
        ewv=filter_moveAvg(ewv,1);
        ewv=ewv-mean(ewv(1:3));
        vamp=max(abs(ewv(round(sum(twin)/2)-5:round(sum(twin)/2)+5)));
        wvs{i,6}=ewv(round(sum(twin)/2)-5:round(sum(twin)/2)+5);
        if vamp<th_vamp;
            wvs{i,1}=99;
        end
    end
    %
    th_vamp2=3;%20
    for i=1:length(wvs(:,1));
        ewv=wvs{i,15};%wvs{i,3}
        ewv=filter_moveAvg(ewv,1);
        pk00=ewv(twin(1)-10:twin(1)+10);
        [va,vai]=max(pk00);
        [vb,vai]=min(pk00);
        vamp2=va-vb;
        if vamp2<th_vamp2;
            wvs{i,1}=99;
        end
    end
    %
    cth=0.75;%
    cth2=0.65;%
    cth=0.45;
    dcc=10;
    for i=1:length(wvs(:,1));
        ewv=wvs{i,15};%wvs{i,3}
        mxx1=tmps{1,1};
        mxx2=tmps{2,1};
        mxx3=tmps{1,3};
        mxx4=tmps{2,3};
        ewv=ewv-mean(ewv(1:5));
        mxx1=mxx1-mean(mxx1(1:5));
        mxx2=mxx2-mean(mxx2(1:5));
        mxx3=mxx3-mean(mxx3(1:5));
        mxx4=mxx4-mean(mxx4(1:5));
        ewv=filter_moveAvg(ewv,1);
        rc1=corr(transpose(mxx1),ewv);
        rc2=corr(transpose(mxx2),ewv);
        rc3=corr(transpose(mxx3),ewv);
        rc4=corr(transpose(mxx4),ewv);
        wvs{i,9}=mxx1;
        wvs{i,10}=mxx2;
        wvs{i,11}=mxx3;
        wvs{i,12}=mxx4;
        %
        wvs{i,7}=[rc1;rc2;rc3;rc4];
        %
        if rc1<cth&&rc2<cth&&rc3<cth2&&rc4<cth2;
            wvs{i,1}=99;
        end
    end
    %
    wvs9=cell(1,1);
    wcnt=1;
    for i=1:length(wvs(:,1));
        if wvs{i,1}~=99;
            wvs9{wcnt,1}=wvs{i,1};
            wvs9{wcnt,2}=wvs{i,14};
            wvs9{wcnt,3}=wvs{i,15};
            wvs9{wcnt,4}=wvs{i,16};
            wvs9{wcnt,5}=wvs{i,5};
            %
            wcnt=wcnt+1;
        end
    end
    %
    if isempty(wvs9{1,1})==1;
        wvs9{1,1}=wvs{1,1};
        wvs9{1,2}=wvs{1,14};
        wvs9{1,3}=wvs{1,15};
        wvs9{1,4}=wvs{1,16};
        wvs9{1,5}=wvs{1,5};
        %
        for i=1:length(wvs9(:,1));
            plot(tax(wvs9{i,4}),dif0(wvs9{i,4}),'x');
        end
    else
        for i=1:length(wvs9(:,1));
            plot(tax(wvs9{i,4}),dif0(wvs9{i,4}),'x');
        end
    end
    %
    %%
    wst1=zeros(1,length(wvs9{1,2}));
    wst2=zeros(1,length(wvs9{1,2}));
    in1=1;
    in2=1;
    %
    yflg=round(linspace(1,max(tax),5));
    yflg2=[yflg(1),yflg(2);yflg(2)+1,yflg(3);yflg(3)+1,yflg(4);yflg(4)+1,yflg(5)];
    %
    subplot(2,1,2);
    plot(tax*t_smp,org0,'-k');hold on
    for i=1:length(wvs9(:,1));
        if wvs9{i,5}==-1;
            plot(wvs9{i,2}*t_smp,wvs9{i,3},'-m');
            v0=transpose(wvs9{i,3});
            if in1==1;
                wst1=v0;
                in1=0;
            else
                wst1=[wst1;v0];
            end
        else
            plot(wvs9{i,2}*t_smp,wvs9{i,3},'-c');
            v0=transpose(wvs9{i,3});
            if in2==1;
                wst2=v0;
                in2=0;
            else
                wst2=[wst2;v0];
            end
        end
        %
        if i==1;
            t_ev=[wvs9{i,4},wvs9{i,4}*t_smp,wvs9{i,5}];
        else
            t_ev=[t_ev;[wvs9{i,4},wvs9{i,4}*t_smp,wvs9{i,5}]];
        end
    end
    set(gca,'box','off');
    set(gca,'tickdir','out');
    %
    for hpp=1:length(yflg2(:,1))-1;
        plot([yflg2(hpp,2),yflg2(hpp,2)]*t_smp,[round(min(org0)*1.05),round(max(org0)*1.05)],'-','linewidth',1,'color',[0.65,0.65,0.65]);
    end
    yflg2=[yflg2,yflg2*t_smp];
    %
    %%
    tax9=[1:length(wst1(1,:))];
    tax9=tax9-round(length(tax9)/2);
    figure('position',[250,300,500,260]);
    subplot(1,2,1);
    for i=1:length(wst1(:,1));
        plot(tax9*t_smp,wst1(i,:),'-','color',[0.65,0.65,0.65]);hold on
    end
    plot(tax9*t_smp,mean(wst1,1),'-k','linewidth',1.2);
    set(gca,'box','off');
    set(gca,'tickdir','out');
    %
    subplot(1,2,2);
    for i=1:length(wst2(:,1));
        plot(tax9*t_smp,wst2(i,:),'-','color',[0.65,0.65,0.65]);hold on
    end
    plot(tax9*t_smp,mean(wst2,1),'-k','linewidth',1.2);
    set(gca,'box','off');
    set(gca,'tickdir','out');
    %%
    wvs2=cell(1,1);
    wvs2{1,1}=fid;
    wvs2{2,1}=wvs;
    wvs2{2,2}=wvs9;
    wvs2{3,1}=wst1;
    wvs2{3,2}=wst2;
    %
    wvs2{5,1}=t_ev;
    wvs2{5,2}='#events';
    wvs2{5,3}=length(t_ev(:,1));
    wvs2{6,2}='rectim[sec]';
    wvs2{6,3}=length(org0)*t_smp;
    wvs2{7,2}='freq[#events/time(seq)]';
    wvs2{7,3}=length(t_ev(:,1))/(length(org0)*t_smp);
    %
    t_ev=[t_ev,zeros(length(t_ev(:,1)),1)];
    for i=1:length(yflg2(:,1));
        t_ev(t_ev(:,1)>=yflg2(i,1)&t_ev(:,1)<=yflg2(i,2),4)=i;
    end
    wvs2{5,3}=t_ev;
    %
    for i=1:length(yflg2(:,1));
        ffdd1=find(t_ev(:,4)==i);
        wvs2{4+i,5}=length(ffdd1);
        wvs2{4+i,6}=(yflg2(i,2)-yflg2(i,1))*t_smp;
        wvs2{4+i,7}=wvs2{4+i,5}/wvs2{4+i,6};
    end
    %
    saveas(figure(1+(reps-1)*2),['trace','-direc#',num2str(reps),'_v2'],'fig');
    saveas(figure(1+(reps-1)*2),['trace','-direc#',num2str(reps),'_v2'],'jpeg');
    saveas(figure(2+(reps-1)*2),['events','-direc#',num2str(reps),'_v2'],'fig');
    saveas(figure(2+(reps-1)*2),['events','-direc#',num2str(reps),'_v2'],'jpeg');
    out=wvs2;
    %
    if reps==1;
        als=cell(1,1);
        als{reps,1}=out;
    else
        als{reps,1}=out;
    end
end
    





outputArg1 = als;
%outputArg2 = inputArg2;
end

