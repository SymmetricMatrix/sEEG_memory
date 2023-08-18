function  pic_pair_labels = find_pic_pair(subject,proj)

switch proj
    case 'object_recognition'
        pic_pair_labels = pic_pair_object(subject);
    case 'sequence_memory'
        % statements to execute if case_expression2 is true
    case 'obj2seq'
        
    otherwise
        error('proj input is wrong')
end

end