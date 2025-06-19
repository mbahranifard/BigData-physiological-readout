close all
clear all
clc

cd('C:\Users\mbahranifard3\Desktop\InjectRaw\');
AnimalRaw = readtable ('Mouse.xlsx','Sheet',1,'Format','auto');
IOPRaw = readtable ('Mouse.xlsx','Sheet',3,'Format','auto','ReadVariableNames',false);
Injected = readtable ('Mouse.xlsx','Sheet',2,'Format','auto');
Baseline = readtable('Baselines.csv','Format','auto');


IOPnum = transpose(IOPRaw{1,:});
IOPnum = rmmissing(IOPnum);
AnimalRmInd = find(contains(IOPnum,'Ani'));
IOPnum(AnimalRmInd) = [];
IOPmat = str2num(cell2mat(IOPnum));
%cell containing which dates to select
SelectCell = table(Baseline.Var4,Baseline.Var5);
Baseline.Var4=[];
Baseline.Var5=[];
rmtemp = [];
AvgIOP = [];
injectMat = Baseline;
injectMat{:,4:1000}=NaN;
AbsIOP = injectMat;  %%% this is to export absolute IOP values


for col = 12:size(AnimalRaw,2)
    Gadjet(1:numel(AnimalRaw.AnimalID),1) = AnimalRaw.AnimalID;
%     Gadjet(1:numel(AnimalRaw.AnimalID),2) = hours((AnimalRaw{:,col}-AnimalRaw.DOB))/(24*30);

%     Gadjet(1:numel(AnimalRaw.AnimalID),5) = HetWTnum;
    
rmtemp = [];

%     GadjetDates(isnan(Gadjet(:,2))) = []; 
%     Gadjet(isnan(Gadjet(:,2)),:) = []; 
    
    
        for i = 1:numel(Injected.AnimalID)

            
            % removing the ones injected
            injrmidx = find(Gadjet(:,1)==Injected.AnimalID(i));
            if ~isempty(injrmidx)
                animaldatetot = AnimalRaw{injrmidx,col};

               
               injrm = hours(animaldatetot-Injected.InjectionDate(i));
               injrm=injrm/24;
%                Gadjet(i,2)= injrm/24;
               if injrm <0
               rmtemp = [rmtemp i]; 

                continue
               end
            else 
                rmtemp = [rmtemp i]; 
                formatSpec = 'animal %d missing\n';
                fprintf(formatSpec,Injected.AnimalID(i))
                continue  
               
            end
            
            
                if isnat(animaldatetot)
                    continue
                end
            %getting the IOP
            K = find(IOPmat == Injected.AnimalID(i));
            
            if ~isempty(K)

                    GadDateStr = string(datestr(animaldatetot,'mm/dd/yyyy'));
                    
                    IOPDATE = datetime(IOPRaw{:,2*K(1)-1},'InputFormat','MM/dd/yyyy');
                    IOPDATE = string(datestr(IOPDATE,'mm/dd/yyyy'));
                    DateFind = find(contains(IOPDATE,GadDateStr));


                if ~isempty(DateFind)
                     %pone = OS, ptwo=OD                   
                    pone = str2num(cell2mat(IOPRaw{DateFind+12,2*K(1)-1}));
                    ptwo = str2num(cell2mat(IOPRaw{DateFind+12,2*K(1)}));
                    stdone = str2num(cell2mat(IOPRaw{DateFind+13,2*K(1)-1}));%std
                    stdtwo = str2num(cell2mat(IOPRaw{DateFind+13,2*K(1)}));
                    %find the baseline
                    baselineidx = find(Baseline.Var1==Injected.AnimalID(i));
                    sidx = (col-12)*3+4;

                     if numel(baselineidx) == 2
                         if Baseline{baselineidx(1),2}=="OS"
                        injectMat{baselineidx(1),sidx+1}= pone-Baseline.Var3(baselineidx(1),1);
                        injectMat{baselineidx(2),sidx+1}= ptwo-Baseline.Var3(baselineidx(2),1);
                        
                        injectMat{baselineidx(1),sidx}= injrm;
                        injectMat{baselineidx(2),sidx}= injrm;
                        
                        injectMat{baselineidx(1),sidx+2}= stdone; %std
                        injectMat{baselineidx(2),sidx+2}= stdtwo;
                        
                        % total Iop
                        AbsIOP{baselineidx(1),sidx+1}= pone;
                        AbsIOP{baselineidx(2),sidx+1}= ptwo;
                        
                        AbsIOP{baselineidx(1),sidx}= injrm;
                        AbsIOP{baselineidx(2),sidx}= injrm;
                        
                        AbsIOP{baselineidx(1),sidx+2}= stdone; %std
                        AbsIOP{baselineidx(2),sidx+2}= stdtwo;
                   
                         else 
                             try  %% one of the eyes didn't have value and it was giving error
                        injectMat{baselineidx(2),sidx+1}= pone-Baseline.Var3(baselineidx(2),1);
                        injectMat{baselineidx(2),sidx}= injrm;
                        injectMat{baselineidx(2),sidx+2}= stdone;
                        
                        AbsIOP{baselineidx(2),sidx+1}= pone;
                        AbsIOP{baselineidx(2),sidx}= injrm;
                        AbsIOP{baselineidx(2),sidx+2}= stdone;
                            catch
                        injectMat{baselineidx(2),sidx+1}= NaN;
                        injectMat{baselineidx(2),sidx}= NaN;
                        injectMat{baselineidx(2),sidx+2}= NaN;
                        
                        AbsIOP{baselineidx(2),sidx+1}= NaN;
                        AbsIOP{baselineidx(2),sidx}= NaN;
                        AbsIOP{baselineidx(2),sidx+2}= NaN;
                             end
                            
                        injectMat{baselineidx(1),sidx+1}= ptwo-Baseline.Var3(baselineidx(1),1);  
                        injectMat{baselineidx(1),sidx}= injrm;
                        injectMat{baselineidx(1),sidx+2}= stdtwo;
                        
                        AbsIOP{baselineidx(1),sidx+1}= ptwo;  
                        AbsIOP{baselineidx(1),sidx}= injrm;
                        AbsIOP{baselineidx(1),sidx+2}= stdtwo;

                       end
                     elseif numel(baselineidx) == 1 & string(Baseline.Var2(baselineidx)) == "OS"
                        injectMat{baselineidx,sidx+1}= pone-Baseline.Var3(baselineidx);
                        injectMat{baselineidx(1),sidx}= injrm;
                        injectMat{baselineidx(1),sidx+2}= stdone; %std
                        
                        AbsIOP{baselineidx,sidx+1}= pone;
                        AbsIOP{baselineidx(1),sidx}= injrm;
                        AbsIOP{baselineidx(1),sidx+2}= stdone; %std
                     else
                        injectMat{baselineidx,sidx+1}= ptwo-Baseline.Var3(baselineidx);
                        injectMat{baselineidx(1),sidx}= injrm;
                        injectMat{baselineidx(1),sidx+2}= stdtwo;
                        
                        AbsIOP{baselineidx,sidx+1}= ptwo;
                        AbsIOP{baselineidx(1),sidx}= injrm;
                        AbsIOP{baselineidx(1),sidx+2}= stdtwo;

                    end
                     
                else 
                 formatSpec = 'Date %s for animal %d missing\n';
                 fprintf(formatSpec,datestr(animaldatetot,'mm/dd/yyyy'),Injected.AnimalID(i))
                end            
            end
        
        end
%         Gadjet(rmtemp,:)=[];
%      AvgIOP = [AvgIOP ;Gadjet];
%      rmtemp = [];
     clear Gadjet K rmtemp
end




cellomat = NaN(size(injectMat,1),6);
totomat =NaN(size(injectMat,1),6);
cellocell = string(NaN(size(injectMat,1),1));
 figure('Units','pixels','WindowStyle','normal','Position',[200,200,500,350]);

 
 
for i = 1:size(injectMat,1)

IOP = rmmissing(injectMat{i,4:1000});
if isempty(IOP)
    continue
end
IOP = [0,0,0,IOP];

IOPtot = rmmissing(AbsIOP{i,4:1000});


plot(IOP(1:3:end), IOP(2:3:end), 'marker','O','linestyle','-','markersize',1,'markerfacecolor','k','MarkerEdgeColor','k','linewidth',1);
str = sprintf('   %u',injectMat{i,1});


text(IOP(end-2),IOP(end-1),str);
% hold all
close all
    for j = 1:2
        % find SelectCell dates in IOP vector
        if contains(SelectCell{i,j},"end")
           IOPmax= length(IOP)-2;
        elseif contains(SelectCell{i,j},"r")
            continue
        else
        IOPmax = find(strcmp(string(IOP(1:3:end)),SelectCell{i,1}));
                IOPmax = IOPmax*3-2;
        end
       
        IOPtotidx = IOPmax-3;
        % find maximum measured IOP
        % [~,IOPmax] = max(abs(IOP(1:3:end)));
        cellomat(i,(3*j-2):3*j)=[IOP(IOPmax:IOPmax+2)];
        cellocell(i)=[strcat(string(rmmissing(injectMat{i,1})),rmmissing(injectMat{i,2}))];
        totomat(i,(3*j-2):3*j)=[IOPtot(IOPtotidx:IOPtotidx+2)]; %sameas cellomat expect absolute IOPs


%         if cellomat(i,1)>45
%             cellomat(i,4)=2;
%         else
%             cellomat(i,4)=1;
% 
%         end
    end
end

 csvwrite('totomat.csv',totomat);
 cellocelltab = table(cellocell);
 write(cellocelltab,'cellocell.csv');


xlim([0 80])
ylim([-12 5])
% set(gca,'xtick',[0,3,7,12],'xticklabel', ["Day 0","Day 3","Day 7", "Day 12"])
ylabel('IOP (mmHg)')
xlabel('Days after injection')


% figure()
% histogram(cellomat(:,1),10)
% set(gcf,'position',[100 100 500 500])

f3=figure(3);set(gca,'fontsize',12)
    ha=tight_subplot(1,1,[.02 .125],[.14 .06],[.15 0.05]);
    set(f3,'position',[100 100 500 500],'color','w')
%     title(Names)
    set(gca,'fontsize',12) 
    Acol={[256 0 0]/256 [0 0 256]/256 [0 192 0]/256 [255 160 64]/256 };                         % Light versions of red and bluw 
Mcol={[256 0 0]/256*.6 [0 0 256]/256*.6 [0 192 0]/256*.6 [255 160 64]/256*.6  [0.7 0 0.7]};  


% groups = unique(cellomat(:,4));

% groups(groups =="Out")=[];

grpidxcell = [];
for i = 1:size(cellomat,2)/3
%     grpidx = find(cellomat(:,4)==groups(i));
%     OutElem = isoutlier(DataRaw.Var3(grpidx),1);
%     grpidx(grpidx == OutElem) = [];
%     grpidxcell = {grpidxcell grpidx};
    Yi{i}  = cellomat(:,3*i-1);
    NameTag{i}=cellocell;
%     [H, pValue, SWstatistic]=swtest(Yi);
%     pValue
    sYi{i} = cellomat(:,3*i); %std of measurement
    rmindx = find(isnan(Yi{i}));
    Yi{i}(rmindx)=[];
    sYi{i}(rmindx)=[];
    NameTag{i}(rmindx)=[];
    
    


end

Captions={"Short-Term","Long-Term"};
maxval=1.1*max(Ybar+4*sqrt(sPop2));
minval = 1.1*min(Ybar-4*sqrt(sPop2));

