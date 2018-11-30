clear all
close all
clc

dbstop if error
%% Nom du fichier
FILENAME = 'treillis123';

%% Definition du treillis

constLen = 3;
codePoly = [7,5];
codeFeedback = 7;
trellis =  poly2trellis(constLen,codePoly,codeFeedback);
codeMemory = constLen-1;


% constLen = 4;
% codePoly = [13,15];
% codeFeedback = 13;
% trellis =  poly2trellis(constLen,codePoly,codeFeedback);
% codeMemory = constLen-1;

% constLen = 7;
% codePoly = [133,171];
% codeFeedback = 133;
% trellis =  poly2trellis(constLen,codePoly,codeFeedback);
% codeMemory = constLen-1;

%% Parametres du tracé
nbrTrellisSection = 1;
boolSoftDec = 0;

typeTransition = {'dashed','solid','dotted','dashdotted'};
numTypeTransition = numel(typeTransition);


% Proprietes des noeuds
nodeColor = 'black';
nodeSize = '2.5pt';

% Proprietes des bords
edgeColor = 'black';
edgeWidth = '1pt';

% Proprietes des chemins
pathColor = 'blue';
pathNodeSize = '2.5pt';
pathEdgeWidth = '1.5pt';

backgoundColor = 'white';

boolDebug = 0; % Booleen affichage du debug (affichage du nom des noeuds sous les noeuds)

boolValues = 0;% Booleen affichage des valeurs

boolOpening = 0; % Booleen pour indiquer l'ouverture
boolClosing = 0; % Booleen pour indiquer la fermeture

boolDispPath = 0;
boolDispStateInfo = 1;
boolDisplayTimeAxis = 0;
%%
type = boolOpening + 2*boolClosing;

nTrans = trellis.numInputSymbols;
nSecTot = nbrTrellisSection + (boolOpening+boolClosing)*codeMemory;
nStateTot = (nbrTrellisSection+1)*trellis.numStates + (boolOpening+boolClosing)*(nTrans^codeMemory - 1)/(nTrans-1);

totState = zeros(nStateTot ,3)-1;% Nombre d'etats total



%%
path = [0 0 2 1 0 0 0 0];

G = cumsum(rand(trellis.numStates,nSecTot+1),2);



%%
indFirstState = 1;
switch type
    case 0
        vecState = 0:trellis.numStates-1;
    case 1
        vecState = 0;
    case 2
        vecState = 0:trellis.numStates-1;
    case 3
        vecState = 0;
end

for iSec = 0:nSecTot-1- codeMemory*boolClosing
    nextState = [];
    
    totState(indFirstState:indFirstState+length(vecState)-1,2) = vecState;
    totState(indFirstState:indFirstState+length(vecState)-1,1) = iSec;
    for iState = 1:length(vecState)
        tempNextState = trellis.nextStates(vecState(iState)+1,:);
        if  boolDispPath == 1
            if path(iSec+1) == vecState(iState)
                totState(indFirstState+iState-1,3)=1;
            else
                totState(indFirstState+iState-1,3)=0;
            end
        end
        nextState = [nextState,tempNextState];
        
    end
    indFirstState = indFirstState + length(vecState);
    vecState = unique(nextState);
end


for iSec = nSecTot - codeMemory*boolClosing:nSecTot-1
    nextState = [];
    
    totState(indFirstState:indFirstState+length(vecState)-1,2) = vecState;
    totState(indFirstState:indFirstState+length(vecState)-1,1) = iSec;
    for iState = 1:length(vecState)
        if  boolDispPath == 1
            if path(iSec+1) == vecState(iState)
                totState(indFirstState+iState-1,3)=1;
            else
                totState(indFirstState+iState-1,3)=0;
            end
        end
        testBit = de2bi(trellis.nextStates(vecState(iState)+1,1),codeMemory);
        if testBit(codeMemory) == 0
            tempNextState = trellis.nextStates(vecState(iState)+1,1);
        else
            tempNextState = trellis.nextStates(vecState(iState)+1,2);
        end
        
        nextState = [nextState,tempNextState];
        
    end
    indFirstState = indFirstState + length(vecState);
    vecState = unique(nextState);
end

totState(indFirstState:indFirstState+length(vecState)-1,2) = vecState;
totState(indFirstState:indFirstState+length(vecState)-1,1) = nSecTot;

for iState = 1:length(vecState)
    if  boolDispPath == 1
        if path(nSecTot+1) == vecState(iState)
            totState(indFirstState+iState-1,3)=1;
        else
            totState(indFirstState+iState-1,3)=0;
        end
    end
end

nStateWithTransition = nStateTot-1*boolClosing-(1-boolClosing)*(trellis.numStates);
totTransition = zeros(nStateWithTransition, trellis.numInputSymbols)-1;% Nombre de transition total
totOutputFromStates = zeros(nStateWithTransition ,trellis.numInputSymbols);% Nombre de transition total

for iState = 1:nStateWithTransition
    if iState > nStateTot-boolClosing*((nTrans^(codeMemory+1) - 1)/(nTrans-1))
        
        testBit = de2bi(trellis.nextStates(totState(iState,2)+1,1),codeMemory);
        if testBit(codeMemory) == 0
            totTransition(iState,1) = trellis.nextStates(totState(iState,2)+1,1);
            totOutputFromStates(iState,1) = trellis.outputs(totState(iState,2)+1,1);
        else
            totTransition(iState,2) = trellis.nextStates(totState(iState,2)+1,2);
            totOutputFromStates(iState,2) = trellis.outputs(totState(iState,2)+1,2);
        end
        
    else
        for iTrans = 1:trellis.numInputSymbols
            totTransition(iState,iTrans) = trellis.nextStates(totState(iState,2)+1,iTrans);
            totOutputFromStates(iState,iTrans) = trellis.outputs(totState(iState,2)+1,iTrans);
        end
    end
    
end

%% Definition des constantes
fid = fopen([FILENAME,'.tex'],'w');

PREAMBULE = '\\documentclass[tikz]{standalone}\n \\usepackage{pgfplots}\n \\usepackage{grffile}\n \\pgfplotsset{compat=newest}\n \\usetikzlibrary{plotmarks}\n \\usepackage{amsmath}\n \\usepackage{pgfplots,tikz} %% Drawing packages \n \\usetikzlibrary{shapes,decorations,arrows,positioning,fit} %% Extensions of tikz package \n \\begin{document}\n';
COLORBGND = ['\\pagecolor{',backgoundColor,'}'];
BEGINTIKZ = '\\begin{tikzpicture} \n';

NODEINFOSTYLE = '\\tikzset{nodeInfoStyle/.style={text = TEXTEDGECOLOR}};\n';
NODESTYLE = '\\tikzset{nodeStyle/.style={circle,fill=NODECOLOR,inner sep=NODESIZE}};\n';
NODE = '\\node [nodeStyle] (Nx%dy%d) at (%d,%d) {};\n';

EDGELABELSTYLE = '\\tikzset{edgeLabelStyle/.style={pos=0.2,fill=BGNDCOLOR, text=TEXTEDGECOLOR,inner sep =0.1pt}};\n';
EDGESTYLE = '\\tikzset{edgeStyle/.style={draw=EDGECOLOR,-latex,shorten >=0.5,line width=EDGEWIDTH, }};\n';
EDGE = '\\path [edgeStyle,%s] (Nx%dy%d) -- (Nx%dy%d) node [edgeLabelStyle] {\\footnotesize $%s$};\n';

PATHNODESTYLE = '\\tikzset{pathNodeStyle/.style={circle,fill=PATHCOLOR,inner sep=PATHNODESIZE}};\n';
PATHEDGESTYLE = '\\tikzset{pathEdgeStyle/.style={draw=PATHCOLOR,-latex,shorten >=0.5,line width=PATHEDGEWIDTH}};\n';
PATHNODE = '\\node [pathNodeStyle] (Nx%dy%d) at (%d,%d) {};\n';
PATHEDGE = '\\path [pathEdgeStyle,%s] (Nx%dy%d) -- (Nx%dy%d) node [edgeLabelStyle] {\\footnotesize $%s$};\n';

ENDTIKZ = '\\end{tikzpicture}\n'; 
ENDDOC = ' \\end{document}';

NODESTYLE = strrep(NODESTYLE,'NODECOLOR',nodeColor);
NODESTYLE = strrep(NODESTYLE,'NODESIZE',nodeSize);

NODEINFOSTYLE = strrep(NODEINFOSTYLE,'TEXTEDGECOLOR',nodeColor);

EDGESTYLE = strrep(EDGESTYLE,'EDGECOLOR',edgeColor);
EDGESTYLE = strrep(EDGESTYLE,'EDGEWIDTH',edgeWidth);

EDGELABELSTYLE = strrep(EDGELABELSTYLE,'BGNDCOLOR',backgoundColor);
EDGELABELSTYLE = strrep(EDGELABELSTYLE,'TEXTEDGECOLOR',edgeColor);

PATHNODESTYLE = strrep(PATHNODESTYLE,'PATHCOLOR',pathColor);
PATHNODESTYLE = strrep(PATHNODESTYLE,'PATHNODESIZE',pathNodeSize);
PATHEDGESTYLE = strrep(PATHEDGESTYLE,'PATHCOLOR',pathColor);
PATHEDGESTYLE = strrep(PATHEDGESTYLE,'PATHEDGEWIDTH',pathEdgeWidth);

%% Ecriture dans fichier
fprintf(fid, PREAMBULE);
fprintf(fid,COLORBGND);
fprintf(fid,BEGINTIKZ);
fprintf(fid, '%% Definition des styles \n');
fprintf(fid, NODESTYLE);
fprintf(fid, NODEINFOSTYLE);

fprintf(fid, EDGESTYLE);
fprintf(fid, EDGELABELSTYLE);
fprintf(fid, PATHNODESTYLE);
fprintf(fid, PATHEDGESTYLE);

fprintf(fid, '\n %% Trace les noeuds \n');
%% On ecrit les noeuds
for iState = 1:nStateTot
    if boolDispPath == 1
        if totState(iState,3) == 1
            fprintf(fid, PATHNODE, totState(iState,1), totState(iState,2), totState(iState,1)*2, -totState(iState,2)*1.5);
        else
            fprintf(fid, NODE, totState(iState,1), totState(iState,2), totState(iState,1)*2, -totState(iState,2)*1.5);
        end
        
    else
        fprintf(fid, NODE, totState(iState,1), totState(iState,2), totState(iState,1)*2, -totState(iState,2)*1.5);
        %         end
    end
end

%% On ecrit les bords
fprintf(fid, '\n %% Trace les bords \n');

for iState = 1:nStateWithTransition
    for iTrans = 1:trellis.numInputSymbols
        
        iTypeTransition = mod(iTrans-1,numTypeTransition)+1;
        etiq = dec2bin(totOutputFromStates(iState,iTrans),log2(trellis.numOutputSymbols));
        
        if boolSoftDec == 1
            etiq = strrep(etiq,'0','+');
            etiq = strrep(etiq,'1','-');
        end
        if totTransition(iState,iTrans)>=0
            if boolDispPath == 1
                if totState(iState,3) == 1 && path(totState(iState,1)+2) == totTransition(iState,iTrans)
                    fprintf(fid, PATHEDGE, typeTransition{iTypeTransition}, totState(iState,1), totState(iState,2),totState(iState,1)+1,totTransition(iState,iTrans), etiq);
                else
                    fprintf(fid, EDGE, typeTransition{iTypeTransition}, totState(iState,1), totState(iState,2),totState(iState,1)+1,totTransition(iState,iTrans), etiq);
                end
                
            else
                fprintf(fid, EDGE, typeTransition{iTypeTransition}, totState(iState,1), totState(iState,2),totState(iState,1)+1,totTransition(iState,iTrans), etiq);
                %         end
            end
        end
    end
end



%% On ecrit les debugs
if boolDebug == 1
    fprintf(fid, '\n %% Trace les noeuds de debug \n');
    for iState = 1:nStateTot
        fprintf(fid, '\\node [color = red,anchor=north] at (Nx%dy%d.south) {\\footnotesize Nx%dy%d};\n', totState(iState,1), totState(iState,2),totState(iState,1), totState(iState,2));
    end
end

%% On ecrit les Valeurs sur les noeuds
if boolValues == 1
    fprintf(fid, '\n %% Trace les valeurs \n');
    for iState = 1:nStateTot
        if totState(iState,3) == 1 && boolDispPath == 1
            fprintf(fid, '\\node [color = %s,anchor=south] at (Nx%dy%d.north) {\\footnotesize \\bf %5.2f};\n',pathColor, totState(iState,1), totState(iState,2),G(totState(iState,2)+1,totState(iState,1)+1));
        else
            fprintf(fid, '\\node [color = %s,anchor=south] at (Nx%dy%d.north) {\\footnotesize  %5.2f};\n', nodeColor, totState(iState,1), totState(iState,2),G(totState(iState,2)+1,totState(iState,1)+1));
        end
    end
end

if boolDispStateInfo == 1
    for iState = 0:trellis.numStates-1
        etiq = dec2bin(iState,log2(trellis.numStates));
        fprintf(fid, '\\node [nodeStyle] (Dx%dy%d) at (%d,%d) {};\n', 0, iState, -1, -iState*1.5);
        fprintf(fid, '\\node [nodeInfoStyle,anchor=east] at (Dx%dy%d.west) {\\footnotesize %s};\n', 0, iState, etiq);
    end
    fprintf(fid, '\\node [nodeInfoStyle] at (-1,0.5) {\\footnotesize \\''Etats};\n');
end

if boolDisplayTimeAxis == 1

fprintf(fid, '\\path [draw, -latex] (-0.5,%5.1f) -- (%5.1f,%5.1f) node [at end, below] {\\footnotesize Temps};\n',-trellis.numStates*1.5+0.9,nSecTot*2+1.5,-trellis.numStates*1.5+0.9);
fprintf(fid, '\\foreach \\i in {0,...,%5.1f}\n{\n \\node [label={below:\\footnotesize \\i}] (t\\i) at (2*\\i,%5.1f) {}; \n \\path [draw] (t\\i.north) -- (t\\i.south); \n }\n', nSecTot,-trellis.numStates*1.5+0.9);

end
fprintf(fid, ENDTIKZ);

fprintf(fid, ENDDOC);
fclose(fid);
setenv('PATH', [getenv('PATH'),':','/Library/Tex/texbin:/Library/Tex']);
system(['pdflatex ', FILENAME])