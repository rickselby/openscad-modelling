echo(concat(1,2,3));

function sumVector(v, i) = (i < 0 ? 0 : (i == 0 ? v[i] : v[i] + sumVector(v, i-1)));

function makeVectorTotal(v, i=0) = 
(i == len(v) ? [] : concat(sumVector(v, i), makeVectorTotal(v, i+1)));

function subVector(v, i=1) = 
(i == len(v) ? [] : concat(v[i], subVector(v, i+1)));

function mergeVectors(v1, v2) = 
(v1 == [] && v2 == [] ? [] : 
	v1 == [] ? concat(v2[0], mergeVectors(v1, subVector(v2))) :
	v2 == [] ? concat(v1[0], mergeVectors(subVector(v1), v2)) :
	(v1[0] == v2[0])
		? concat(v1[0], mergeVectors(subVector(v1), subVector(v2))) :
	(v1[0] < v2[0])
		? concat(v1[0], mergeVectors(subVector(v1), v2))
		: concat(v2[0], mergeVectors(v1, subVector(v2)))
		);
	


echo(makeVectorTotal([10,20,10]), subVector([10,20,10]));

echo(mergeVectors([10,20,30,40],[20,35,40,45]));