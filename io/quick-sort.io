# inplace quick sort written in Io language

quicksort := algorithm(array, begin, end) {
	begin = begin ifNilEval(0)
	end = end ifNilEval(array size - 1)

	length := end - begin + 1
	
	if(length == 2) then(
		if(array at(begin) > array at(end)) then(
			array swapIndices(begin, end)
		)
	)elseif(length > 2) then(
		pivot := array at(begin)
		i := begin + 1
		j := end

		while(i <= j,
			pivot := array at(i-1)
			value := array at(i)

			if(value > pivot) then(
				array swapIndices(i, j)
				j = j - 1
			)else(
				array swapIndices(i, i-1)
				i = i + 1
			)
		)

		quicksort call(array, begin, i-2)
		quicksort call(array, j+1, end)
	)

	return array
}

quicksort call(
	list(5,2,-1,1,0)
) println

