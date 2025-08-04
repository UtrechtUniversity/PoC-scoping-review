# Initialize results dataframe with new columns
results <- data.frame(
  record_id = character(),
  author = character(),
  year = numeric(),
  journal = character(),
  doi = character(),
  title = character(),
  pages = character(),
  volume = character(),
  number = character(),
  abstract = character(),
  isbn = character(),
  label = character(),
  source = character(),
  issn = character(),
  publication_type = character(),  # <-- added this line
  stringsAsFactors = FALSE
)

# Process in batches
batch_size <- 50
for(i in seq(1, total_count, batch_size)) {
  cat(sprintf("Retrieving articles %d to %d of %d\n", i, min(i + batch_size - 1, total_count), total_count))
  
  # Get batch of records
  batch_results <- entrez_search(db="pubmed", term=query, 
                                 retstart=i-1, retmax=batch_size)
  
  if(length(batch_results$ids) > 0) {
    # Fetch the full records for this batch
    records <- entrez_fetch(db="pubmed", id=batch_results$ids, 
                            rettype="xml", parsed=TRUE)
    
    # Process each article in the batch
    articles <- XML::xpathApply(records, "//*[(name()='PubmedArticle' or name()='PubmedBookArticle')]")
    
    for(article in articles) {
      # Extract record_id (PubMed ID)
      record_id <- XML::xpathSApply(article, ".//PubmedData//ArticleId[@IdType='pubmed']", XML::xmlValue)
      record_id <- if(length(record_id) > 0) record_id[1] else NA
      
      # Extract authors
      authors <- XML::xpathSApply(article, ".//AuthorList//Author//LastName", XML::xmlValue)
      authors <- paste(authors, collapse=", ")  # Combine multiple authors
      
      # Extract year
      year <- XML::xpathSApply(article, ".//PubDate//Year", XML::xmlValue)
      year <- if(length(year) > 0) as.numeric(year[1]) else NA
      
      # Extract journal
      journal <- XML::xpathSApply(article, ".//Journal//Title", XML::xmlValue)
      journal <- if(length(journal) > 0) journal[1] else NA
      
      # Extract ISSN
      issn <- XML::xpathSApply(article, ".//Journal//ISSN", XML::xmlValue)
      issn <- if(length(issn) > 0) issn[1] else NA
      
      # Extract DOI
      doi <- XML::xpathSApply(article, ".//ArticleId[@IdType='doi']", XML::xmlValue)
      doi <- if(length(doi) > 0) doi[1] else NA
      
      # Extract title
      title <- XML::xpathSApply(article, ".//ArticleTitle", XML::xmlValue)
      title <- if(length(title) > 0) title[1] else NA
      
      # Extract abstract
      abstract <- XML::xpathSApply(article, ".//Abstract/AbstractText", XML::xmlValue)
      abstract <- if(length(abstract) > 0) paste(abstract, collapse=" ") else NA
      
      # Extract pages
      pages <- XML::xpathSApply(article, ".//Pagination//MedlinePgn", XML::xmlValue)
      pages <- if(length(pages) > 0) pages[1] else NA
      
      # Extract volume
      volume <- XML::xpathSApply(article, ".//JournalIssue//Volume", XML::xmlValue)
      volume <- if(length(volume) > 0) volume[1] else NA
      
      # Extract number
      number <- XML::xpathSApply(article, ".//JournalIssue//Issue", XML::xmlValue)
      number <- if(length(number) > 0) number[1] else NA
      
      # Extract ISBN (if available)
      isbn <- XML::xpathSApply(article, ".//Book//ISBN", XML::xmlValue)
      isbn <- if(length(isbn) > 0) isbn[1] else NA
      
      # Extract label (if available, otherwise NA)
      label <- NA  # Add logic if 'label' exists in the XML structure
      
      # Extract source (source is usually publisher or similar, but may need a custom field)
      source <- NA  # Add logic if 'source' exists in the XML structure
      
      # Extract publication type
      publication_type <- XML::xpathSApply(article, ".//PublicationTypeList/PublicationType", XML::xmlValue)
      publication_type <- if(length(publication_type) > 0) paste(publication_type, collapse=", ") else NA  # <-- added
      
      # Add to results
      results <- rbind(results, data.frame(
        record_id = record_id,
        author = authors,
        year = year,
        journal = journal,
        doi = doi,
        title = title,
        pages = pages,
        volume = volume,
        number = number,
        abstract = abstract,
        isbn = isbn,
        label = label,
        source = source,
        issn = issn,
        publication_type = publication_type, 
        stringsAsFactors = FALSE
      ))
    }
  }
  
  # Add a small delay to be gentle to the server
  Sys.sleep(0.5)
}

