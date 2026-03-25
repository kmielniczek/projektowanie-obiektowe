program exercise1;
var
    arr1, arr2: array of integer;

procedure generate(var arr: array of integer; min, max, n: integer);
var
    i: integer;
begin
    for i := 0 to n - 1 do arr[i] := random(max + 1 - min) + min;
end;

procedure generate(var arr: array of integer);
begin
    generate(arr, 0, 100, length(arr));
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

function compareArrays(var arr1, arr2: array of integer): boolean;
var
    i: integer;
begin
    if length(arr1) <> length(arr2) then
    begin
        compareArrays := false;
        exit;
    end;

    for i := 0 to high(arr1) do
    begin
        if arr1[i] <> arr2[i] then
        begin
            compareArrays := false;
            exit;
        end;
    end;

    compareArrays := true;
end;

function checkArrayValuesRange(var arr: array of integer; min, max, n: integer): boolean;
var
    i: integer;
begin
    for i := 0 to n - 1 do
    begin
        if (arr[i] < min) or (arr[i] > max) then
        begin
            checkArrayValuesRange := false;
            exit
        end;
    end;

    checkArrayValuesRange := true;
end;

procedure test(num: integer; desc: string; res: boolean);
var
    result: string;
begin
    if res then
        result := 'passed'
    else
        result := 'failed';

    writeln('test ', num, ' - ', desc, ': ', result, '.')
end;

begin
    randomize(); { initialize random number generator }

    setLength(arr1, 50);
    setLength(arr2, 50);

    generate(arr1);
    generate(arr2);
    test(1, 'generate procedure produces different arrays', not compareArrays(arr1, arr2));

    generate(arr1, 30, 40, length(arr1));
    test(2, 'generated values are within specified range', checkArrayValuesRange(arr1, 30, 40, length(arr1)));

    arr1 := [3, 12, 23, 43, 45, 77, 86];
    arr2 := [3, 12, 23, 43, 45, 77, 86];
    bubbleSort(arr1);
    test(3, 'bubblesort keeps sorted array unchanged', compareArrays(arr1, arr2));

    arr1 := [45, 23, 86, 3, 43, 77, 12];
    arr2 := [3, 12, 23, 43, 45, 77, 86];
    bubbleSort(arr1);
    test(4, 'bubblesort correctly sorts array with different values', compareArrays(arr1, arr2));

    arr1 := [45, 86, 23, 77, 86, 45, 3, 43, 77, 86, 12];
    arr2 := [3, 12, 23, 43, 45, 45, 77, 77, 86, 86, 86];
    bubbleSort(arr1);
    test(5, 'bubblesort correctly sorts array with duplicate values', compareArrays(arr1, arr2));
end.
