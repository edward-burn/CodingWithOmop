#' @title Draw exclusion diagram
#' @description Draw a diagram with from exclusion matrices
#' @param list_matrices list of tibble of the different exclusion matrices
#' @param Relation relation between the different exclusion matrices
#' @param nom full path and name to save the resulting diagram
#' @return no return
#' @export compute_diagram
#' @examples
#' list_matrices2 = NULL
#' list_matrices2$matrix1 = tibble::tibble(N = c(15000,12000),Label = c("TOTS",">50 anys"))
#' list_matrices2$matrix2 = tibble::tibble(N = c(11000,10500,8500),Label = c("A","B","C"))
#' list_matrices2$matrix3 = tibble::tibble(N = c(10300,7000,4200,850),Label = c("ABCD","EFGH","IJKLMN","OPQRST"))
#' relation = tibble::tibble(mother = c("matrix1","matrix1"), daughter = c("matrix2","matrix3"))
#' compute_diagram(list_matrices2,relation,"C:/Users/martics/OneDrive - Nexus365/MCToolsTest/MCToolsTest/prova67.svg")
#'
compute_diagram <- function(list_matrices,Relation,nom){

  nice.num <- function(x,n=0) {
    trimws(format(round(x,n),big.mark=",", nsmall = n, digits=n, scientific=FALSE))
  }

  declaration <- "digraph {graph [overlap = true]
  node [shape = box, fontname = Helvetica, color = black]
  edge [color = black, fixedsize = true, width = 1.5]"
  nodes  <- NULL
  edges  <- NULL
  labels <- NULL
  l      <- 1

  first_node <- NULL
  last_node  <- NULL
  nam        <- names(list_matrices)
  for (i in 1:length(list_matrices)){
    nam.i <- paste0("list_matrices$",nam[i])
    eval(parse(text=paste0(nam.i,"$Nstr <-nice.num(as.numeric(",nam.i,"$N))")))
    first_node <- c(first_node,l)
    for (k in 1:nrow(eval(parse(text=nam.i)))) {
      node  <- paste0("m",l," [label = '@@",l,"']")
      nodes <- paste(nodes, node, sep = "\n")
      if (k>1) {
        edge  <- paste0("m",l-1," -> m",l,";")
        edges <- paste(edges, edge, sep = "\n")
      }
      label  <- paste0("[",l,"]: paste0(",nam.i,"$Label[",k,"],' (N = ',",nam.i,"$Nstr[",k,"],')')")
      labels <- paste(labels, label, sep = "\n")
      l      <- l + 1
    }
    last_node <- c(last_node,l-1)
  }

  for (i in 1:nrow(Relation)){

    mo    <- Relation$mother[i]
    im    <- which(names(list_matrices)==mo)
    i1    <- last_node[im]

    da    <- Relation$daughter[i]
    id    <- which(names(list_matrices)==da)
    i2    <- first_node[id]

    edge  <- paste0("m",i1," -> m",i2,";")
    edges <- paste(edges, edge, sep = "\n")

  }

  diagram <- paste0(declaration,nodes,edges,"}",labels,sep="\n")
  xml2::write_xml(xml2::read_xml(charToRaw(DiagrammeRsvg::export_svg(DiagrammeR::grViz(diagram)))),nom)

}
