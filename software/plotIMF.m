%plotData(0,1440);
plotData(time2minutes(6,0),time2minutes(8,30), {360:10:510;{'6:00','6:10','6:20','6:30','6:40','6:50','7:00','7:10','7:20','7:30','7:40','7:50','8:00','8:10','8:20','8:30'}});
%plotData(1050,1430, {1050:10:1430;{'17:30', '17:40','17:50','18:00','18:10','18:20','18:30','18:40','18:50','19:00','19:10','19:20','19:30','19:40','19:50','20:00','20:10','20:20','20:30','20:40','20:50','21:00','21:10','21:20','21:30','21:40','21:50','22:00','22:10','22:20','22:30','22:40','22:50','23:00','23:10','23:20','23:30','23:40','23:50'}});
function plotData(start, finish, labels)
    if (~exist('labels', 'var'))
        labels = {0:120:1440;{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'}};
    end
    ACE = readtable("../data input/20031029_ace_mag_1m.csv");
    SYM_H = readtable("../data input/20031029_sym_h_1m.csv");
    AEI = readtable("../data input/20031029_Auroral_Electrojet_1_m.csv");
    ACE.Bx(ACE.Bx == -999.9) = NaN;
    ACE.By(ACE.By == -999.9) = NaN;
    ACE.Bz(ACE.Bz == -999.9) = NaN;
    
    figure;
    tbl=table((0:1439)', ACE.By, ACE.Bz, AEI.SMU, AEI.SML, 'VariableNames',{'Time','By','Bz', 'SMU', 'SML'});
    tbl=table((0:1439)', ACE.By, ACE.Bz, AEI.SMU, AEI.SML, SYM_H.SYM_H, 'VariableNames',{'Time','By','Bz', 'SMU','SML','SYM_H'});
    tbl=table((0:1439)', AEI.SML, 'VariableNames',{'Time','SML'});
    plt = stackedplot(tbl, "Xvariable","Time", "Title", "SML on October 29, 2003","DisplayLabels",["SML (nT)"]);
    ax = findobj(plt.NodeChildren, 'Type','Axes');
    plt.XLimits = [start finish];
    plt.XLabel = "Time (hour)";
    set(ax,'XTick',labels{1},'XTickLabel',labels{2})
   % plt.LineProperties(1).Color = [0 0.4470 0.7410];
    %plt.LineProperties(2).Color = [0.8500 0.3250 0.0980];
    %plt.LineProperties(3).Color = [0.9290 0.6940 0.1250];
    %plt.LineProperties(4).Color = [0.4940 0.1840 0.5560];
    %plt.LineProperties(5).Color = [0 0.5 0];
    plt.FontName = "Arial";
    plt.FontSize = 9;
    
    
    x0=10;
    y0=10;
    width=900;
    height=600;
    set(gcf,'position',[x0,y0,width,height]);
end

function minutes = time2minutes(hour, minute)
  minutes = hour*60 + minute;
end