% REAL MAIN

close all;
clear all;

init_globals();

while true
    image = get_input();
    results = process(image);
    do_output(results);
end