# fillmap.dpr

### Problem:

Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor. Bu harita üzerinde, rastgele seçilen ve boş olan bir noktadan başlayarak boşlukların doldurulması istenmektedir. 

### Kural:

Eğer bir nokta "varsayılan" değer ile doluysa o nokta geçilmeli ve doğru yol bulunarak boşluk doldurulmaya devam edilmelidir.

## EN

### Problem:

The map with a size of mxn and a pattern by default is given at the beginning. On this map, it is requested to fill in the blanks starting from a randomly selected and empty point.

### Rule:

If a point is filled with the "default" value, that point should be passed and the gap should be continued by finding the correct path.

# fillmap2.dpr

### Problem:

Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor. Haritanın eş parçalara bölünerek, her parçanın rastgele seçilen ve boş bir noktadan başlayarak boşluklarının eş zamansız (asynch) ve paralel (multi task) şekilde doldurulması istenmektedir.

### Kural:

Eğer bir nokta "varsayılan" değer ile doluysa o nokta geçilmeli ve doğru yol bulunarak boşluk doldurulmaya devam edilmelidir.

Bu proje belirtilen problemi çözmek için geliştirildi.

## EN

### Problem:

The map with a size of mxn and a pattern by default is given at the beginning. By dividing the map into equal parts, each part is asked to fill in the blanks asynchronously (asynch) and parallel (multi-task) starting from a randomly selected and empty point.

### Rule: 

If a point is filled with the "default" value, that point should be passed and the gap should be continued by finding the correct path.

# fillmap3.dpr

### Problem: 

Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor. Haritanın eş parçalara bölünerek, her parçanın rastgele seçilen ve boş bir noktadan başlayarak boşluklarının eş zamansız (asynch) ve paralel (multi task) şekilde doldurulması istenmektedir.

### Kural: 

Eğer bir nokta "varsayılan" değer ile doluysa o nokta geçilmeli ve doğru yol bulunarak boşluk doldurulmaya devam edilmelidir.

## EN

### Problem: 

Initially mxn size and patterned map is given by default. The map is divided into equal parts and each part is asked to fill in the blanks asynchronously (asynchronously) and parallel (multitasking), starting from a randomly chosen and empty point.

### Rule: 

If a point is filled with a "default" value, that point must be passed and the space must be continued by finding the right path.

# fillmap4.dpr

### Problem:

Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor. Bu harita üzerinde, rastgele seçilen ve boş olan bir noktadan başlayarak boşlukların doldurulması istenmektedir. Problem "Pointer" ve "Bağlı Liste" kullanırarak çözülmüştür.

### Kural:

Eğer bir nokta "varsayılan" değer ile doluysa o nokta geçilmeli ve doğru yol bulunarak boşluk doldurulmaya devam edilmelidir.

## EN

### Problem:

The map with a size of mxn and a pattern by default is given at the beginning. On this map, it is requested to fill in the blanks starting from a randomly selected and empty point. Problem solved using "Pointer" and "Linked List".

### Rule:

If a point is filled with the "default" value, that point should be passed and the gap should be continued by finding the correct path.

# fillmap5.dpr

### Problem:

Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor. Bu harita üzerinde, rastgele seçilen ve boş olan bir noktadan başlayarak boşlukların doldurulması istenmektedir.
Klasik programlama yaklaşımı, doğrusal bellek erişimi (lineer memory access) ve göstergeç (pointer) kullanılarak çözülmüştür.

### Kural:

Eğer bir nokta "varsayılan" değer ile doluysa o nokta geçilmeli ve doğru yol bulunarak boşluk doldurulmaya devam edilmelidir.

## EN

### Problem:

The map with a size of mxn and a pattern by default is given at the beginning. On this map, it is requested to fill in the blanks starting from a randomly selected and empty point.
The classical programming approach is solved using linear memory access and pointer.
