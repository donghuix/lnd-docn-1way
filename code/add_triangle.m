function [tx, ty, tc] = add_triangle(ax,xlab,ylab,zlab)
tcorner = [0.0, 0.5,             1.0; % x
           0.0, 1.0*sqrt(3)/2,   0.0]; % y
tg = triangle_grid( 1/0.05, tcorner);
tgx = tg(1,:);
tgy = tg(2,:);

% Create triangles
tri = delaunay(tgx,tgy);
irm = [];
for i = 1 : size(tri,1)
    x = tgx(tri(i,:));
    y = tgy(tri(i,:));
    if polyarea(x,y) < 1e-6
        irm = [irm; i];
    end
end
tri(irm,:) = [];

xc = nanmean(tgx(tri),2);
yc = nanmean(tgy(tri),2);
x = 1 - xc - yc./tan(pi/3);
y = yc./sin(pi/3);
z = 1 - x - y;
z(z < 0) = 0;

col = [x y z];
col= brighten(col,0.3);
for i = 1 : size(tri,1)
    fill(ax,tgx(tri(i,:))',tgy(tri(i,:))',col(i,:),'EdgeColor','none'); hold on;
end

tx = tgx(tri)';
ty = tgy(tri)';
tc = col;

% setting the axes:
grid off;
ax.YAxis.Visible = 'off';
ax.XAxis.Visible = 'off';
ticks = (100:-20:20).';

% % bottom axis:
% tickpos = linspace(tcorner(1,1),tcorner(1,3),numel(ticks)+1);
% ax.XAxis.FontSize = 14;
% ax.XAxis.TickValues = tickpos(1:end-1);
% ax.XAxis.TickLabels = ticks;
% ax.XAxis.TickLabelRotation = -45;
% xlabel(xlab,'FontSize',15,'FontWeight','bold');


% left & right axis:
ticksxpos = linspace(tcorner(1,1),tcorner(1,3),numel(ticks)*2+1);
ticksypos = linspace(tcorner(2,1),tcorner(2,2),numel(ticks)+1);

text(ticksxpos(1:2:10),... % bottom
    zeros(5,1)-0.025,...
    num2str(ticks),'FontSize',14,...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','left','Rotation',-60);

text(ticksxpos(numel(ticks)+1:-1:2)-0.1,... % left
    ticksypos(end:-1:2),...
    num2str(ticks),'FontSize',14,...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','left');
text(ticksxpos(end:-1:numel(ticks)+2)+0.115,... % right
    ticksypos(1:end-1)+0.01,...
    num2str(ticks),'FontSize',14,...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','right',...
    'Rotation',60);
ax.Parent.Color = 'w';

% titles:
text(tcorner(1,2),-0.15,...
    xlab,'FontSize',15,'FontWeight','bold',...
    'HorizontalAlignment','center');
text(tcorner(1,2)/2-0.125,tcorner(2,2)/2+0.06,...
    ylab,'FontSize',15,'FontWeight','bold',...
    'HorizontalAlignment','center',...
    'Rotation',60);
text(tcorner(1,2)+tcorner(1,2)/2+0.125,tcorner(2,2)/2+0.06,...
    zlab,'FontSize',15,'FontWeight','bold',...
    'HorizontalAlignment','center',...
    'Rotation',-60);
set(gca,'box','off','color','none'); axis equal;
end

function tg = triangle_grid(n, t)
    ng = ( ( n + 1 ) * ( n + 2 ) ) / 2;
    tg = zeros ( 2, ng );

    p = 0;

    for i = 0 : n
        for j = 0 : n - i
            k = n - i - j;
            p = p + 1;
            tg(1:2,p) = ( i * t(1:2,1) + j * t(1:2,2) + k * t(1:2,3) ) / n;
        end
    end
end