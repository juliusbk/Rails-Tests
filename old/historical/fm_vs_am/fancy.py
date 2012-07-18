def fancyTable(arrays):

 def areAllEqual(lst):
     return not lst or [lst[0]] * len(lst) == lst

 if not areAllEqual(map(len, arrays)):
  exit('Cannot print a table with unequal array lengths.')

 #lengths = [map(len, a) for a in myar]
 #sizes = map(lambda * x:x, *lengths)
 #maxSize = [max(a) for a in sizes]

 verticalMaxLengths = [max(value) for value in map(lambda * x:x, *[map(len, a) for a in arrays])]

 spacedLines = []

 for array in arrays:
  spacedLine = ''
  for i, field in enumerate(array):
   diff = verticalMaxLengths[i] - len(field)
   spacedLine += field + ' ' * diff + '\t'
  spacedLines.append(spacedLine)

 return '\n'.join(spacedLines)