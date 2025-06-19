close all
clear all
clc
cd('C:\Users\mbahranifard3\Desktop\');
AnimalRaw = readtable ('IOPInjected.csv');
AnimalID = AnimalRaw {:,1};
DayPI = AnimalRaw {:,2};
IOP = AnimalRaw{:,4};
AnimalUQ = unique(AnimalID);

    figure('Units','pixels','WindowStyle','normal','Position',[200,200,500,350]);

for i = 1:numel(AnimalUQ)

idxtemp = find(AnimalID==AnimalUQ(i));
plot(DayPI(idxtemp), IOP(idxtemp), 'marker','O','linestyle','-','markersize',1,'markerfacecolor','k','MarkerEdgeColor','k','linewidth',1);
str = sprintf('   %u',AnimalUQ(i));
text(DayPI(idxtemp(end)),IOP(idxtemp(end)),str);
hold all
% plot(xiop, yiopOD, 'marker','O','linestyle','-','markersize',7,'markerfacecolor','b','linewidth',2,'Color','b','MarkerEdgeColor','k');
% errorbar(xiop, yiopOD,errOD,'color','k','linestyle','none')
% errorbar(xiop,yiopOS,errOS,'color','k','linestyle','none')
end

xlim([0 47])
ylim([-12 40])
% set(gca,'xtick',[0,3,7,12],'xticklabel', ["Day 0","Day 3","Day 7", "Day 12"])
ylabel('IOP (mmHg)')
xlabel('Days after injection')
