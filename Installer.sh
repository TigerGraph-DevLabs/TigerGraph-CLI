#!/bin/bash
echo "*** GSQL Graph Algorithm Installer ***"
fExt="_file"
aExt="_attr"

countStringInFile() {
	echo $(grep -c $1 $2)
}
countVertexType() {
	echo $(grep -c "\- VERTEX" schema.$grph)
}
ifEdgeType() {
	echo $(grep -c "RECTED EDGE $1" schema.$grph)
}	
countVertexAttr() {
	echo $(grep "\- VERTEX" schema.$grph|grep -c $1)
}
countEdgeAttr() {
	echo $(grep "RECTED EDGE" schema.$grph|grep -c $1)
}

# 1. Select a graph (done only once)
echo "Available graphs:" 
gsql ls | grep "\- Graph "
read -p 'Graph name? ' grph
grph=${grph//[[:space:]]/}

if [ "${grph}" == "" ]; then
    echo "Graph name cannot be empty."
    exit 1
fi
gsql -g $grph ls > schema.$grph
if [[ $(countVertexType) == 0 ]]; then
	echo "Bad graph name(?) No vertices found."
	exit 1
fi

# 2. Select an algorithm.  After finishing, loop again to select another algorithm.
finished=false
while [ !$finished ]; do
	echo; echo "Please enter the index of the algorithm you want to create or EXIT:"
  
	select algo in "EXIT" "PageRank" "Weighted PageRank" "Personalized PageRank" "Triangle Counting(minimal memory)" "Triangle Counting(fast, more memory)" "Jaccard Neighbor Similarity (single vertex)" "Jaccard Neighbor Similarity (all vertices)"; do   # "Cosine Similarity (single vertex)" "Jaccard Similarity (single vertex)" 

    	case $algo in
			"PageRank" )
				algoName="pageRank"
				echo "  pageRank() works on directed edges"
				break;;
      "Weighted PageRank" )
        algoName="pageRank_wt"
        echo "  pageRank_wt() works on directed edges"
        break;;
      "Personalized PageRank" )
        algoName="pageRank_pers"
        echo "  pageRank_pers() works on directed edges"
        break;;
			"Triangle Counting(minimal memory)" )
				algoName="tri_count"
				echo "  tri_count() works on undirected edges"
				break;;
			'Triangle Counting(fast, more memory)' )
				algoName="tri_count_fast"
				echo "  tri_count_fast() works on undirected graphs"
				break;;
	                'Jaccard Neighbor Similarity (single vertex)' )
                                algoName="jaccard_nbor_ss"
                                echo "  jaccard_nbor_ss() calculates the similarity between one given vertex and all other vertices"
                                break;;
                        'Jaccard Neighbor Similarity (all vertices)' )
                                algoName="jaccard_nbor_ap"
                                echo "  jaccard_nbor_ap() calculates the similarity between all vertices"
                                break;;
			"EXIT" )
				finished=true
				break;;
			* )
				echo "Not a valid choice. Try again."
				;;
		esac
	done
	if [[ $finished == true ]]; then
		echo "Exiting"
		break
	fi

	# Copy the algorithm template file to the destination file.
	templPath="./templates"
	genPath="./generated"
	mkdir -p ./generated;
	cp ${templPath}/${algoName}.gtmp ${genPath}/${algoName}_tmp.gsql;

	# Replace *graph* placeholder
	sed -i "s/\*graph\*/$grph/g" ${genPath}/${algoName}_tmp.gsql
	
	echo; echo "Available vertex and edge types:"
	gsql -g $grph ls|grep '\- VERTEX\|\DIRECTED EDGE'
	echo
	echo "Please enter the vertex type(s) and edge type(s) for running ${algo}."
	echo "   Use commas to separate multiple types [ex: type1, type2]"
	echo "   Leaving this blank will select all available types"
	echo " Similarity algorithms only take single vertex type"
	echo

	# 3. Ask for vertex types. Replace *vertex-types* placeholder. For similarity algos, only take one vertex type.
	read -p 'Vertex types: ' vts
	vts=${vts//[[:space:]]/}
	if [[ $algoName == *cosine* ]] || [[ $algoName == *jaccard* ]]; then 
		sed -i "s/\*vertex-types\*/$vts/g" ${genPath}/${algoName}_tmp.gsql
        elif [[ $algoName == "shortest_ss_pos_w" ]]; then
		sed -i "s/\*vertex-types\*/$vts/g" ${genPath}/${algoName}_tmp.gsql		
	elif [ "${vts}" == "" ]; then
		vts="ANY"
	else
		vts=${vts//,/.*, }   # replace the delimiter
		vts="${vts}.*"
	fi
	sed -i "s/\*vertex-types\*/$vts/g" ${genPath}/${algoName}_tmp.gsql
	

	# 4. Ask for edge types. Replace *edge-types* placeholder.
	read -p 'Edge types: ' egs
	egs=${egs//[[:space:]]/}

	#Outdegree() and neighbors() processing
	edgeFuncProc(){
		OIFS=$IFS
		IFS=','
		egsinp=$egs
		outshold=($egsinp)
		if [ "${outshold}" != "" ]
			then
				outs="${4}.${1}(\"${outshold}\")"
		else
			outs="${4}.${1}()"
		fi
		for x in $egsinp
		do
			if [ "${x}" != "${outshold}" ]
				then
					outs="${outs} ${3} ${4}.${1}(\"$x\")"
			fi
		done
		sed -i "s/\*${2}\*/$outs/g" ${genPath}/${algoName}_tmp.gsql
		IFS=$OIFS
	}

	# Why not run this for all algorithms? Then we don't have to keep CASEs up to date.
	#case $algoName in
	#	"pageRank" )
	#	edgeFuncProc outdegree s_outdegrees + s;;
	#	"tri_count" )
		edgeFuncProc neighbors s_neighbors UNION s;
		edgeFuncProc neighbors t_neighbors UNION t;
	#	"tri_count_fast" )
		edgeFuncProc outdegree s_outdegrees + s;
		edgeFuncProc outdegree t_outdegrees + t;
	#esac

	#if [[ $egs = *","* ]]; then
		egs=${egs//,/|}
		egs="${egs}"
	#fi
	sed -i "s/\*edge-types\*/$egs/g" ${genPath}/${algoName}_tmp.gsql

	# 4.2 Ask for reverse edge type for similarity algos. 
        if [[ $algoName == *cosine* ]] || [[ $algoName == *jaccard* ]]; then
		read -p 'Second Hop Edge type: ' edge2
                edge2=${edge2//[[:space:]]/}
		sed -i "s/\*sec-edge-types\*/$edge2/g" ${genPath}/${algoName}_tmp.gsql
	fi

	# 4.3 Ask for reverse edge type for directed edges.
        if [[ $algoName == scc ]]; then
                read -p 'Reverse Edge Type: ' edge3
                edge3=${edge3//[[:space:]]/}
		#if [[ $edge3 = *","* ]]; then
                	edge3=${edge3//,/|}
                	edge3="${edge3}"
        	#fi
                sed -i "s/\*reverse-edge-types\*/$edge3/g" ${genPath}/${algoName}_tmp.gsql
		sed -i "s/)|(/|/g" ${genPath}/${algoName}_tmp.gsql
        fi

     	# 5. Ask for edge weight name. Replace *edge-weight* placeholder.
	if [ "${algoName}" == "shortest_ss_pos_wt" ] || [ "${algoName}" == "shortest_ss_any_wt" ] || [ "${algoName}" == "pageRank_wt" ] || [ "${algoName}" == "mst" ] || [ "${algoName}" == "msf" ] || [ "${algoName}" == "louvain_parallel" ]; then
		while true; do
                	read -p "Edge attribute that stores FLOAT weight:"  weight
			if [[ $(countEdgeAttr $weight) > 0 ]]; then
				sed -i "s/\*edge-weight\*/$weight/g" ${genPath}/${algoName}_tmp.gsql
				break;
			else
				echo " *** Edge attribute name not found. Try again."
			fi
		done
        fi

        if [[ ${algoName} == *cosine* ]]; then
        	while true; do
	        	read -p "Edge attribute that stores FLOAT weight, leave blank if no such attribute:"  weight
                        weight=${weight//[[:space:]]/}
                        if [ "${weight}" == "" ]; then   #when there is no weight attribute, use unified weight
				sed -i "s/e\.\*edge-weight\*/1/g" ${genPath}/${algoName}_tmp.gsql
				break; 
			elif [[ $(countEdgeAttr $weight) > 0 ]]; then   #when there is the weight attribute
                                sed -i "s/\*edge-weight\*/$weight/g" ${genPath}/${algoName}_tmp.gsql
				break;
			else
                                echo " *** Edge attribute name not found. Try again."
                        fi
		done
        fi

        # 6. Ask for vertex label attribute name. Replace *vertex-label* placeholder.
        if [[ ${algoName} == knn_cosine* ]]; then
                while true; do
                        read -p "Vertex attribute that stores STRING label:"  label
                        if [[ $(countVertexAttr $label) > 0 ]]; then
                                sed -i "s/\*vertex-label\*/$label/g" ${genPath}/${algoName}_tmp.gsql
                                break;
                        else
                                echo " *** Vertex attribute name not found. Try again."
                        fi
                done
        fi

: <<'END'
	# 6. Drop queries and subqueries in order
	gsql -g $grph "DROP QUERY ${algoName}"
	gsql -g $grph "DROP QUERY ${algoName}$fExt"
	gsql -g $grph "DROP QUERY ${algoName}$aExt"
	# Search for subqueries and drop them
	# DOESN'T YET WORK FOR MULTIPLE SUBQUERIES BELONGING TO ONE MAIN QUERY
	subqueryClue="\*SUB\* CREATE QUERY"
	subqueryLine=$(grep "$subqueryClue" ${genPath}/${algoName}.gsql)
	if [[ $(grep -c "$subqueryClue" ${genPath}/${algoName}.gsql) > 0 ]]; then
		subqueryWords=( $subqueryLine )
		gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
	fi
END

        # 6. Ask for query mode.
       echo; echo "Please choose query mode:"
       select mode in "Single Node Mode" "Distributed Mode"; do
                case $mode in
                        "Distributed Mode" )	
                                sed -i "s/CREATE QUERY/CREATE DISTRIBUTED QUERY/g" ${genPath}/${algoName}_tmp.gsql;
                                break;;
                        "Single Node Mode" )
                                break;;
                        * )
                                echo "Not a valid choice. Try again."
                                ;;
                esac
        done

###################################################
# 7. Create up to 3 versions of the algorithm:
# ${algoName}      produces JSON output
# ${algoName}$fExt writes output to a file
# ${algoName}$aExt saves output to graph attribute (if they exist)

	echo; echo "Please choose a way to show result (Contact TigerGraph Support for higher performance File version):"
        select version in "Show JSON result" "Write to File" "Save to Attribute/Insert Edge" "All of the above"; do
        	case $version in
        		"Show JSON result" )
                                mv ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}.gsql;
				sed -i 's/\*EXT\*//g' ${genPath}/${algoName}.gsql;
				sed -i '/^\*ATTR\*/ d' ${genPath}/${algoName}.gsql;  # Delete lines with *ATTR*
                                sed -i 's/\*ACCM\*CREATE/CREATE/g' ${genPath}/${algoName}.gsql;
                                sed -i 's/\*ACCM\*\*SUB\*/\*SUB\*/g' ${genPath}/${algoName}.gsql;
                                sed -i 's/\*ACCM\*/      /g' ${genPath}/${algoName}.gsql;  # Cut the *ACCM* string, replace by 6 spaces
                                sed -i '/^\*FILE\*/ d' ${genPath}/${algoName}.gsql; # Delete lines with *FILE*
				gsql -g $grph "DROP QUERY ${algoName}"
				subqueryClue="\*SUB\* CREATE QUERY"
				subqueryLine=$(grep "$subqueryClue" ${genPath}/${algoName}.gsql)
				if [[ $(grep -c "$subqueryClue" ${genPath}/${algoName}.gsql) > 0 ]]; then
					subqueryWords=( $subqueryLine )
					gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
				fi
                		# Finalize the JSON (ACCMulator) version of the query
        			sed -i 's/\*SUB\* //g' ${genPath}/${algoName}.gsql;   # Cut the *SUB* string
        			echo; echo "gsql -g $grph ${genPath}/${algoName}.gsql"
        			gsql -g $grph ${genPath}/${algoName}.gsql
                                break;;
			
			"Write to File" )
				# Finalize the FILE output version of the query
				mv ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}$fExt.gsql;
				# Check if this algorithm has *FILE*
				if [[ $(grep -c "\*FILE\*" ${genPath}/${algoName}$fExt.gsql) == 0 ]]; then
                			rm ${genPath}/${algoName}$fExt.gsql
        			else
                			sed -i "s/\*EXT\*/$fExt/g" ${genPath}/${algoName}$fExt.gsql;  # *EXT* -> $fExt
					sed -i '/^\*ATTR\*/ d' ${genPath}/${algoName}$fExt.gsql; # Del *ATTR* lines
					sed -i '/^\*ACCM\*/ d' ${genPath}/${algoName}$fExt.gsql; # Del *ACCM* lines
                                        sed -i 's/\*FILE\*CREATE/CREATE/g' ${genPath}/${algoName}$fExt.gsql; # Cut *FILE* string
                                        sed -i 's/\*FILE\*\*SUB\*/\*SUB\*/g' ${genPath}/${algoName}$fExt.gsql;
					sed -i 's/\*FILE\*/      /g' ${genPath}/${algoName}$fExt.gsql; # Cut *FILE* string in query body
					gsql -g $grph "DROP QUERY ${algoName}$fExt"
					subqueryClue="\*SUB\* CREATE QUERY"
					subqueryLine=$(grep "$subqueryClue" ${genPath}/${algoName}$fExt.gsql)
					if [[ $(grep -c "$subqueryClue" ${genPath}/${algoName}$fExt.gsql) > 0 ]]; then
						subqueryWords=( $subqueryLine )
						gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
					fi

					sed -i 's/\*SUB\* //g' ${genPath}/${algoName}$fExt.gsql;   # Cut the *SUB* string
					echo; echo gsql -g $grph ${genPath}/${algoName}$fExt.gsql
					gsql -g $grph ${genPath}/${algoName}$fExt.gsql
				fi
				break;;
			"Save to Attribute/Insert Edge" )	
				mv ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}$aExt.gsql;
				# Check if this algorithm has *ATTR*
				if [[ $(grep -c "\*ATTR\*" ${genPath}/${algoName}$aExt.gsql) == 0 ]]; then
					rm ${genPath}/${algoName}$aExt.gsql
				else
				  # Finalize the ATTR version of the query
				  echo; echo "If your graph schema has appropriate vertex or edge attributes,"
				  echo " you can update the graph with your results."
				  read -p 'Do you want to update the graph [yn]? ' updateG
                                        
                                  # if you update attribute here, you also need to do the same update in the "All of the above" choice
				  case $updateG in [Yy]*)
					attrQuery=${genPath}/${algoName}$aExt.gsql
					# *vIntAttr*
					if [[ $(countStringInFile "\*vIntAttr\*" $attrQuery) > 0 ]]; then
					  while true; do
						read -p "Vertex attribute to store INT result (e.g. component ID): " vIntAttr
						if [[ $(countVertexAttr $vIntAttr) > 0 ]]; then
							sed -i "s/\*vIntAttr\*/$vIntAttr/g" ${genPath}/${algoName}$aExt.gsql;
							break;
						else
							echo " *** Vertex attribute name not found. Try again."
						fi
					  done
					fi

                                        # *vBoolAttr*
                                        if [[ $(countStringInFile "\*vBoolAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Vertex attribute to store BOOL result (e.g. in_cycle): " vBoolAttr
                                                if [[ $(countVertexAttr $vBoolAttr) > 0 ]]; then
                                                        sed -i "s/\*vBoolAttr\*/$vBoolAttr/g" ${genPath}/${algoName}$aExt.gsql;
                                                        break;
                                                else
                                                        echo " *** Vertex attribute name not found. Try again."
                                                fi
                                          done
                                        fi

					# * vFltAttr*
					if [[ $(countStringInFile "\*vFltAttr\*" $attrQuery) > 0 ]]; then
					  while true; do
						read -p "Vertex attribute to store FLOAT result (e.g. pageRank): " vFltAttr
						if [[ $(countVertexAttr $vFltAttr) > 0 ]]; then
							sed -i "s/\*vFltAttr\*/$vFltAttr/g" $attrQuery;
							break;
						else
							echo " *** Vertex attribute name not found. Try again."
						fi
					  done
					fi

					# * vStrAttr*
					if [[ $(countStringInFile "\*vStrAttr\*" $attrQuery) > 0 ]]; then
					  while true; do
						read -p "Vertex attribute to store STRING result (e.g. path desc): " vStrAttr
						if [[ $(countVertexAttr $vStrAttr) > 0 ]]; then
							sed -i "s/\*vStrAttr\*/$vStrAttr/g" $attrQuery;
							break;
						else
							echo " *** Vertex attribute name not found. Try again."
						fi
					  done
					fi

                                        # * eBoolAttr*
                                        if [[ $(countStringInFile "\*eBoolAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Edge attribute to store BOOL result (e.g. mst): " eBoolAttr
                                                if [[ $(countEdgeAttr $eBoolAttr) > 0 ]]; then
                                                        sed -i "s/\*eBoolAttr\*/$eBoolAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Edge attribute name not found. Try again."
                                                fi
                                          done
                                        fi
					
					# edge to insert for similarity algorithms
					if [[ $(countStringInFile "\*insert-edge-name\*" $attrQuery) > 0 ]]; then
					  while true; do
                                                read -p "Name of the edge to insert and store FLOAT result (e.g. insert \"similarity\" edge with one FLOAT attribute called \"score\"): " edgeName
                                                if [[ $(ifEdgeType $edgeName) > 0 ]]; then
                                                        sed -i "s/\*insert-edge-name\*/$edgeName/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Edge not found. Try again."
                                                fi
                                          done
					fi
					sed -i "s/\*EXT\*/$aExt/g" $attrQuery; # *EXT* > $aExt
                                        sed -i 's/\*ATTR\*CREATE/CREATE/g' $attrQuery;  # Cut *ATTR* string
                                        sed -i 's/\*ATTR\*\*SUB\*/\*SUB\*/g' $attrQuery;
					sed -i 's/\*ATTR\*/      /g' $attrQuery;  # Cut *ATTR* string in query body
					sed -i '/^\*ACCM\*/ d' $attrQuery;  # Del *ACCM* lines
					sed -i '/^\*FILE\*/ d' $attrQuery;  # Del *FILE*lines
					gsql -g $grph "DROP QUERY ${algoName}$aExt"
					subqueryClue="\*SUB\* CREATE QUERY"
					subqueryLine=$(grep "$subqueryClue" $attrQuery)
					if [[ $(grep -c "$subqueryClue" $attrQuery) > 0 ]]; then
						subqueryWords=( $subqueryLine )
						gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
					fi				
					sed -i 's/\*SUB\* //g' $attrQuery;   # Cut the *SUB* string
					echo gsql -g $grph $attrQuery;
					gsql -g $grph $attrQuery;
				  ;;
				  esac
				fi
				break;;
                        "All of the above")
                                #ACCUM version
                                cp ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}.gsql;
                                sed -i 's/\*EXT\*//g' ${genPath}/${algoName}.gsql;
                                sed -i '/^\*ATTR\*/ d' ${genPath}/${algoName}.gsql;  # Delete lines with *ATTR*
                                sed -i 's/\*ACCM\*CREATE/CREATE/g' ${genPath}/${algoName}.gsql;
                                sed -i 's/\*ACCM\*\*SUB\*/\*SUB\*/g' ${genPath}/${algoName}.gsql;
                                sed -i 's/\*ACCM\*/      /g' ${genPath}/${algoName}.gsql;  # Cut the *ACCM* string, replace by 6 spaces
                                sed -i '/^\*FILE\*/ d' ${genPath}/${algoName}.gsql; # Delete lines with *FILE*
                                gsql -g $grph "DROP QUERY ${algoName}"
                                subqueryClue="\*SUB\* CREATE QUERY"
                                subqueryLine=$(grep "$subqueryClue" ${genPath}/${algoName}.gsql)
                                if [[ $(grep -c "$subqueryClue" ${genPath}/${algoName}.gsql) > 0 ]]; then
                                        subqueryWords=( $subqueryLine )
                                        gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
                                fi
                                # Finalize the JSON (ACCMulator) version of the query
                                sed -i 's/\*SUB\* //g' ${genPath}/${algoName}.gsql;   # Cut the *SUB* string
                                echo; echo "gsql -g $grph ${genPath}/${algoName}.gsql"
                                gsql -g $grph ${genPath}/${algoName}.gsql
                        
                                #FILE version
                                # Finalize the FILE output version of the query
                                cp ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}$fExt.gsql;
                                # Check if this algorithm has *FILE*
                                if [[ $(grep -c "\*FILE\*" ${genPath}/${algoName}$fExt.gsql) == 0 ]]; then
                                        rm ${genPath}/${algoName}$fExt.gsql
                                else
                                        sed -i "s/\*EXT\*/$fExt/g" ${genPath}/${algoName}$fExt.gsql;  # *EXT* -> $fExt
                                        sed -i '/^\*ATTR\*/ d' ${genPath}/${algoName}$fExt.gsql; # Del *ATTR* lines
                                        sed -i '/^\*ACCM\*/ d' ${genPath}/${algoName}$fExt.gsql; # Del *ACCM* lines
                                        sed -i 's/\*FILE\*CREATE/CREATE/g' ${genPath}/${algoName}$fExt.gsql; # Cut *FILE* string
                                        sed -i 's/\*FILE\*\*SUB\*/\*SUB\*/g' ${genPath}/${algoName}$fExt.gsql;
                                        sed -i 's/\*FILE\*/      /g' ${genPath}/${algoName}$fExt.gsql; # Cut *FILE* string in query body
                                        gsql -g $grph "DROP QUERY ${algoName}$fExt"
                                        subqueryClue="\*SUB\* CREATE QUERY"
                                        subqueryLine=$(grep "$subqueryClue" ${genPath}/${algoName}$fExt.gsql)
                                        if [[ $(grep -c "$subqueryClue" ${genPath}/${algoName}$fExt.gsql) > 0 ]]; then
                                                subqueryWords=( $subqueryLine )
                                                gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
                                        fi

                                        sed -i 's/\*SUB\* //g' ${genPath}/${algoName}$fExt.gsql;   # Cut the *SUB* string
                                        echo; echo gsql -g $grph ${genPath}/${algoName}$fExt.gsql
                                        gsql -g $grph ${genPath}/${algoName}$fExt.gsql
                                fi

                                #ATTR version
                                mv ${genPath}/${algoName}_tmp.gsql ${genPath}/${algoName}$aExt.gsql;
                                # Check if this algorithm has *ATTR*
                                if [[ $(grep -c "\*ATTR\*" ${genPath}/${algoName}$aExt.gsql) == 0 ]]; then
                                        rm ${genPath}/${algoName}$aExt.gsql
                                else
                                  # Finalize the ATTR version of the query
                                  echo; echo "If your graph schema has appropriate vertex or edge attributes,"
                                  echo " you can update the graph with your results."
                                  read -p 'Do you want to update the graph [yn]? ' updateG

                                  case $updateG in [Yy]*)
                                        attrQuery=${genPath}/${algoName}$aExt.gsql
                                        # *vIntType*
                                        if [[ $(countStringInFile "\*vIntAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Vertex attribute to store INT result (e.g. component ID): " vIntAttr
                                                if [[ $(countVertexAttr $vIntAttr) > 0 ]]; then
                                                        sed -i "s/\*vIntAttr\*/$vIntAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Vertex attribute name not found. Try again."
                                                fi
                                          done
                                        fi

                                        # *vBoolAttr*
                                        if [[ $(countStringInFile "\*vBoolAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Vertex attribute to store BOOL result (e.g. in_cycle): " vBoolAttr
                                                if [[ $(countVertexAttr $vBoolAttr) > 0 ]]; then
                                                        sed -i "s/\*vBoolAttr\*/$vBoolAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Vertex attribute name not found. Try again."
                                                fi
                                          done
                                        fi

                                        # * vFltType*
                                        if [[ $(countStringInFile "\*vFltAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Vertex attribute to store FLOAT result (e.g. pageRank): " vFltAttr
                                                if [[ $(countVertexAttr $vFltAttr) > 0 ]]; then
                                                        sed -i "s/\*vFltAttr\*/$vFltAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Vertex attribute name not found. Try again."
                                                fi
                                          done
                                        fi

                                        # * vStrType*
                                        if [[ $(countStringInFile "\*vStrAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Vertex attribute to store STRING result (e.g. path desc): " vStrAttr
                                                if [[ $(countVertexAttr $vStrAttr) > 0 ]]; then
                                                        sed -i "s/\*vStrAttr\*/$vStrAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Vertex attribute name not found. Try again."
                                                fi
                                          done
                                        fi

                                        # * eBoolType*
                                        if [[ $(countStringInFile "\*eBoolAttr\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Edge attribute to store BOOL result (e.g. flag): " eBoolAttr
                                                if [[ $(countEdgeAttr $eBoolAttr) > 0 ]]; then
                                                        sed -i "s/\*eBoolAttr\*/$eBoolAttr/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Edge attribute name not found. Try again."
                                                fi
                                          done
                                        fi

                                        # edge to insert for similarity algorithms
                                        if [[ $(countStringInFile "\*insert-edge-name\*" $attrQuery) > 0 ]]; then
                                          while true; do
                                                read -p "Name of the edge to insert and store FLOAT result (e.g. insert \"Similarity\" edge with one FLOAT attribute called \"score\"): " edgeName
                                                if [[ $(ifEdgeType $edgeName) > 0 ]]; then
                                                        sed -i "s/\*insert-edge-name\*/$edgeName/g" $attrQuery;
                                                        break;
                                                else
                                                        echo " *** Edge not found. Try again."
                                                fi
                                          done
                                        fi
                                        sed -i "s/\*EXT\*/$aExt/g" $attrQuery; # *EXT* > $aExt
                                        sed -i 's/\*ATTR\*CREATE/CREATE/g' $attrQuery;  # Cut *ATTR* string
                                        sed -i 's/\*ATTR\*\*SUB\*/\*SUB\*/g' $attrQuery;
                                        sed -i 's/\*ATTR\*/      /g' $attrQuery;  # Cut *ATTR* string in query body
                                        sed -i '/^\*ACCM\*/ d' $attrQuery;  # Del *ACCM* lines
                                        sed -i '/^\*FILE\*/ d' $attrQuery;  # Del *FILE*lines
                                        gsql -g $grph "DROP QUERY ${algoName}$aExt"
                                        subqueryClue="\*SUB\* CREATE QUERY"
                                        subqueryLine=$(grep "$subqueryClue" $attrQuery)
                                        if [[ $(grep -c "$subqueryClue" $attrQuery) > 0 ]]; then
                                                subqueryWords=( $subqueryLine )
                                                gsql -g $grph "DROP QUERY ${subqueryWords[3]}"
                                        fi
                                        sed -i 's/\*SUB\* //g' $attrQuery;   # Cut the *SUB* string
                                        echo gsql -g $grph $attrQuery;
                                        gsql -g $grph $attrQuery;
                                  ;;
                                  esac
                                fi
                                break;;
                        * )
                                echo "Not a valid choice. Try again."
                                ;;
                esac
        done

	echo "Created the following algorithms:"
	gsql -g $grph ls | grep $algoName
	echo
done
rm schema.$grph

# 8. Install the queries
read -p "Algorithm files have been created. Do want to install them now [yn]? " doInstall
case $doInstall in
	[Yy] )
		gsql -g $grph INSTALL QUERY ALL
		;;
	* )
		exit;;
esac