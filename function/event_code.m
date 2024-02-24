function code = event_code(sub_id)
% return sequence meomry task code,subject 1,4 changed data_sw
% data,therefor changed code

formal=[ones(3*18,1);ones(3*18,1)*2;ones(3*18,1)*3;ones(3*18,1)*4];
switch sub_id
    case {2,3,12,13,16,18,21,24,25,27,28,29,31,32,33,34,35,36,38}%234
        code=[zeros(1*18,1);formal];
    case {8,9,10,11,15,17,20,26}%252
        code=[zeros(2*18,1);formal];
    case -1
        code=[zeros(2*18,1);formal;ones(1*18,1)*5];
    case -4
        code=[zeros(1*18,1);ones(3*18,1);ones(3*18,1)*2;ones(4*18,1)*3;ones(4*18,1)*4];
    case 7
        code=[zeros(3*18,1);formal];
    case 5
        code=[zeros(4*18,1);formal];
    case {1,4,19,30,37} %216
        code=formal;
    case {6,14,22,23}
        code = [];
       
end