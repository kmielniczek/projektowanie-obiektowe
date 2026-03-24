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

begin
    randomize(); { initialize random number generator }

    generate(arr);

    write('[');
    for i := 0 to high(arr) - 1 do write(arr[i], ', ');
    writeln(arr[high(arr)], ']');
end.
