% REAL MAIN

close all;
clear all;

tic

while true
    image = get_input();
    results = process(image);
    do_output(results);
end