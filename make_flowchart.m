function detailed_flowchart()
% DETAILED FLOWCHART with 7 descriptive steps

clf; figure('Color','w','Units','normalized','Position',[0.15 0.1 0.6 0.8]);
ax = axes('Position',[0 0 1 1]); axis(ax,[0 1 0 1]); axis off; hold(ax,'on');

% Helper
    function makeBox(y,str)
        rectangle('Position',[0.2 y 0.6 0.1],'FaceColor',[0.9 0.95 1], ...
                  'EdgeColor','k','LineWidth',1.5,'Curvature',0.05);
        text(0.5,y+0.05,str,'HorizontalAlignment','center', ...
             'FontSize',10,'FontName','Arial','Interpreter','none');
    end
    function arrow(y1,y2)
        annotation('arrow',[0.5 0.5],[y1 y2],'LineWidth',1.5);
    end

% Y positions
Y = [0.9 0.75 0.6 0.45 0.3 0.15 0.0];

makeBox(Y(1),"Start: Initialize program");

makeBox(Y(2),"Load Data: Import tracking file (CSV/TXT)");

makeBox(Y(3),"Clean Data: Remove NaN rows & invalid entries");

makeBox(Y(4),"Parse Columns: Extract time + marker (x,y) arrays");

makeBox(Y(5),"Check Marker Order: Verify A–B–C–D sequence");

makeBox(Y(6),"Plot & Animate: x–t & y–t plots + leg animation");

makeBox(Y(7),"End / Save Results: Output plots & animations");

title('Detailed MATLAB Data Processing Flowchart','FontSize',13,'FontWeight','bold');
end

