program exercise1;
var
    arr: array[0..49] of integer;
    i: integer;

procedure generate(var arr: array of integer);
var
    i: integer;
begin
    for i := 0 to high(arr) do arr[i] := random(101);
end;

procedure bubbleSort(var arr: array of integer);
var
    i, j, temp: integer;
begin
    for i := 0 to high(arr) - 1 do
        for j := 0 to high(arr) - i - 1 do
            if arr[j] > arr[j + 1] then
            begin
                temp := arr[j];
                arr[j] := arr[j + 1];
                arr[j + 1] := temp;
            end;
end;

begin
    randomize(); { initialize random number generator }

    generate(arr);

    write('[');
    for i := 0 to high(arr) - 1 do write(arr[i], ', ');
    writeln(arr[high(arr)], ']');

    bubbleSort(arr);

    write('[');
    for i := 0 to high(arr) - 1 do write(arr[i], ', ');
    writeln(arr[high(arr)], ']');
end.
