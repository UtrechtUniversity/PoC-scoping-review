PRISMA_flowdiagram_modified <- function(data, interactive = FALSE, previous = TRUE, other = TRUE, 
                                        detail_databases = FALSE, detail_registers = FALSE, 
                                        fontsize = 7, font = "Helvetica", title_colour = "Goldenrod1", 
                                        greybox_colour = "Gainsboro", main_colour = "Black", 
                                        arrow_colour = "Black", arrow_head = "normal", arrow_tail = "none", 
                                        side_boxes = TRUE,
                                        # New parameters for citation processing
                                        citations_duplicates = 0, citations_screened = 0, 
                                        citations_excluded_asreview = 0) {
  
  # NOTE: Adaptations to the PRISMA_flowdiagram function from the PRISMA 2020 package (https://doi.org/10.1002/cl2.1230)
  # were largely done via prompting to Anthropic Claude (Sonnet 4 model).
  
  # Helper functions
  PRISMA_get_pos_ <- function(start, spacing, width, target_width) {
    start + spacing + width/2 + target_width/2
  }
  
  PRISMA_get_height_ <- function(line_count, min_height) {
    max(min_box_height, 0.15 * line_count + 0.4)
  }
  
  # More robust JavaScript function that investigates SVG structure
  PRISMA_insert_js_ <- function(x, identification_text, screening_text, included_text) {
    js_code <- '
    function addRotatedLabels() {
      console.log("=== Starting rotated labels attempt ===");
      
      var svg = document.querySelector("svg");
      if (!svg) {
        console.log("SVG not found, retrying...");
        setTimeout(addRotatedLabels, 300);
        return;
      }
      
      // First, let\'s investigate the SVG structure
      console.log("SVG found, investigating structure...");
      var allGroups = svg.querySelectorAll("g");
      console.log("Total groups found:", allGroups.length);
      
      // Look for our target nodes and log their structure
      var targetNodes = ["identification", "screening", "included"];
      var foundNodes = {};
      
      for (var i = 0; i < allGroups.length; i++) {
        var group = allGroups[i];
        var titleElement = group.querySelector("title");
        
        if (titleElement) {
          var nodeId = titleElement.textContent;
          if (targetNodes.indexOf(nodeId) !== -1) {
            console.log("Found target node:", nodeId);
            foundNodes[nodeId] = group;
            
            // Log the structure of this group
            console.log("Group children for " + nodeId + ":");
            for (var j = 0; j < group.children.length; j++) {
              console.log("  - " + group.children[j].tagName);
            }
            
            // Look for text elements anywhere in this group
            var textElements = group.querySelectorAll("text");
            console.log("Text elements in " + nodeId + ":", textElements.length);
            
            // Look for shape elements
            var shapes = group.querySelectorAll("polygon, rect, ellipse, path");
            console.log("Shape elements in " + nodeId + ":", shapes.length);
          }
        }
      }
      
      // Try to add rotated text to each found node
      var labelMap = {
        "identification": "Identification",
        "screening": "Screening", 
        "included": "Included"
      };
      
      var successCount = 0;
      
      for (var nodeId in foundNodes) {
        if (foundNodes.hasOwnProperty(nodeId)) {
          var group = foundNodes[nodeId];
          var labelText = labelMap[nodeId];
          
          console.log("Processing node:", nodeId);
          
          // Try multiple strategies to find and modify text
          var success = false;
          
          // Strategy 1: Look for existing text element
          var textElement = group.querySelector("text");
          if (textElement) {
            console.log("Found text element for " + nodeId);
            success = addRotationToText(textElement, group, labelText, nodeId);
          }
          
          // Strategy 2: Create new text element if no existing one
          if (!success) {
            console.log("Creating new text element for " + nodeId);
            success = createNewRotatedText(group, labelText, nodeId);
          }
          
          if (success) {
            successCount++;
          }
        }
      }
      
      console.log("Successfully processed " + successCount + " out of " + targetNodes.length + " nodes");
      
      // Retry if not all successful
      if (successCount < targetNodes.length) {
        console.log("Retrying in 500ms...");
        setTimeout(addRotatedLabels, 500);
      }
    }
    
    function addRotationToText(textElement, group, labelText, nodeId) {
      try {
        // Find a shape to get center coordinates
        var shape = group.querySelector("polygon, rect, ellipse, path");
        if (!shape) {
          console.log("No shape found for " + nodeId);
          return false;
        }
        
        var bbox = shape.getBBox();
        var centerX = bbox.x + bbox.width / 2;
        var centerY = bbox.y + bbox.height / 2;
        
        console.log("Shape bbox for " + nodeId + ":", bbox);
        
        textElement.setAttribute("x", centerX);
        textElement.setAttribute("y", centerY);
        textElement.setAttribute("text-anchor", "middle");
        textElement.setAttribute("dominant-baseline", "central");
        textElement.setAttribute("transform", "rotate(-90 " + centerX + " " + centerY + ")");
        textElement.setAttribute("font-size", "11");
        textElement.setAttribute("font-weight", "bold");
        textElement.setAttribute("fill", "black");
        textElement.textContent = labelText;
        
        console.log("Successfully rotated text for " + nodeId);
        return true;
      } catch(e) {
        console.error("Error rotating text for " + nodeId + ":", e);
        return false;
      }
    }
    
    function createNewRotatedText(group, labelText, nodeId) {
      try {
        var shape = group.querySelector("polygon, rect, ellipse, path");
        if (!shape) {
          console.log("No shape found to create text for " + nodeId);
          return false;
        }
        
        var bbox = shape.getBBox();
        var centerX = bbox.x + bbox.width / 2;
        var centerY = bbox.y + bbox.height / 2;
        
        var newText = document.createElementNS("http://www.w3.org/2000/svg", "text");
        newText.setAttribute("x", centerX);
        newText.setAttribute("y", centerY);
        newText.setAttribute("text-anchor", "middle");
        newText.setAttribute("dominant-baseline", "central");
        newText.setAttribute("transform", "rotate(-90 " + centerX + " " + centerY + ")");
        newText.setAttribute("font-size", "11");
        newText.setAttribute("font-weight", "bold");
        newText.setAttribute("fill", "black");
        newText.setAttribute("font-family", "Arial, sans-serif");
        newText.textContent = labelText;
        
        group.appendChild(newText);
        
        console.log("Successfully created new rotated text for " + nodeId);
        return true;
      } catch(e) {
        console.error("Error creating text for " + nodeId + ":", e);
        return false;
      }
    }
    
    // Start the process with multiple attempts
    setTimeout(addRotatedLabels, 500);
    setTimeout(addRotatedLabels, 1500);
    setTimeout(addRotatedLabels, 3000);
    '
    
    js_script <- htmltools::tags$script(htmltools::HTML(js_code))
    
    if (requireNamespace("htmlwidgets", quietly = TRUE) && requireNamespace("htmltools", quietly = TRUE)) {
      x <- htmlwidgets::appendContent(x, js_script)
    }
    return(x)
  }
  
  PRISMA_interactive_ <- function(x, urls, previous, other) {
    return(x)
  }
  
  # Load data variables
  for (var in seq_len(length(data))) {
    assign(names(data)[var], data[[var]])
  }
  
  # Initialize positioning variables
  diagram_start_x <- 0
  diagram_start_y <- 0
  prev_study_width <- 0
  prev_study_offset <- 0
  prev_study_height <- 0
  total_studies_height <- 0
  other_identified_height <- 0
  other_sought_reports_height <- 0
  other_notretrieved_height <- 0
  other_assessed_height <- 0
  other_excluded_height <- 0
  default_box_width <- 3.5
  min_box_height <- 0.5
  default_box_spacing <- 0.5
  section_label_length <- 0.4
  top_box_width <- default_box_width * 2 + default_box_spacing
  
  # Initialize strings
  A <- ""
  Aedge <- ""
  bottomedge <- ""
  previous_nodes <- ""
  finalnode <- ""
  prev_rank1 <- ""
  prevnode1 <- ""
  prevnode2 <- ""
  
  # Text wrapping for data frames
  if (exists("dbr_excluded") && is.data.frame(dbr_excluded)) {
    dbr_excluded[, 1] <- stringr::str_wrap(dbr_excluded[, 1], width = 35)
  }
  if (exists("other_excluded") && is.data.frame(other_excluded)) {
    other_excluded[, 1] <- stringr::str_wrap(other_excluded[, 1], width = 35)
  }
  if (exists("database_specific_results") && is.data.frame(database_specific_results)) {
    database_specific_results[, 1] <- stringr::str_wrap(database_specific_results[, 1], width = 35)
  }
  if (exists("register_specific_results") && is.data.frame(register_specific_results)) {
    register_specific_results[, 1] <- stringr::str_wrap(register_specific_results[, 1], width = 35)
  }
  
  # Previous studies logic
  if ((is.na(previous_studies) || previous_studies == 0) && (is.na(previous_reports) || previous_reports == 0)) {
    previous <- FALSE
  }
  
  if (previous == TRUE) {
    if (is.na(previous_studies) == TRUE || previous_studies == 0) {
      cond_prevstud <- ""
    } else {
      cond_prevstud <- stringr::str_wrap(paste0("Studies included in previous version of review (n = ", previous_studies, ")"), width = 40)
    }
    
    if (is.na(previous_reports) == TRUE || previous_reports == 0) {
      cond_prevrep <- ""
    } else {
      cond_prevrep <- paste0(stringr::str_wrap("Reports of studies included in previous version of review", width = 40), "\n(n = ", previous_reports, ")")
    }
    
    if ((is.na(previous_studies) == TRUE || previous_studies == 0) || (is.na(previous_reports) == TRUE || previous_reports == 0)) {
      dbl_br <- ""
    } else {
      dbl_br <- "\n"
    }
    
    prev_study_label <- paste0(cond_prevstud, dbl_br, cond_prevrep)
    total_studies_label <- paste0(stringr::str_wrap(paste0("Total studies included in review (n = ", total_studies, ")"), width = 33), "\n", stringr::str_wrap(paste0("Reports of total included studies (n = ", total_reports, ")"), width = 33))
    
    prev_study_width <- default_box_width * 2
    prev_study_offset <- default_box_spacing
    prev_box_x <- PRISMA_get_pos_(diagram_start_x, default_box_spacing, default_box_width, prev_study_offset)
    prev_study_height <- PRISMA_get_height_(stringr::str_count(prev_study_label, "\n"), min_box_height)
    total_studies_height <- PRISMA_get_height_(stringr::str_count(total_studies_label, "\n"), min_box_height)
  }
  
  # Enhanced "other" methods section
  if ((is.na(website_results) || website_results == 0) && 
      (is.na(organisation_results) || organisation_results == 0) && 
      (is.na(citations_results) || citations_results == 0)) {
    other <- FALSE
  }
  
  if (other == TRUE) {
    # Citation identification
    if (!is.na(website_results) && website_results > 0) {
      cond_websites <- paste0("\nBackward (ascendant) citations (n = ", website_results, ")")
    } else {
      cond_websites <- ""
    }
    
    if (!is.na(organisation_results) && organisation_results > 0) {
      cond_organisation <- paste0("\nOrganisations (n = ", organisation_results, ")")
    } else {
      cond_organisation <- ""
    }
    
    if (!is.na(citations_results) && citations_results > 0) {
      cond_citation <- paste0("\nForward (descendant) citations (n = ", citations_results, ")")
    } else {
      cond_citation <- ""
    }
    
    # Citation processing boxes
    citations_duplicates_label <- paste0("Citation duplicates removed\n(n = ", citations_duplicates, ")")
    citations_screened_label <- paste0("Citations screened\n(n = ", citations_screened, ")")
    citations_excluded_asreview_label <- paste0("Citations excluded by ASReview\n(n = ", citations_excluded_asreview, ")")
    
    # Calculate heights for new boxes
    citations_duplicates_height <- PRISMA_get_height_(stringr::str_count(citations_duplicates_label, "\n"), min_box_height)
    citations_screened_height <- PRISMA_get_height_(stringr::str_count(citations_screened_label, "\n"), min_box_height)
    citations_excluded_asreview_height <- PRISMA_get_height_(stringr::str_count(citations_excluded_asreview_label, "\n"), min_box_height)
    
    # Other exclusion logic
    if (exists("other_excluded")) {
      if (is.data.frame(other_excluded)) {
        if (ncol(other_excluded) >= 2) {
          other_excluded_data <- paste0(":", paste(paste("\n", other_excluded[, 1], " (n = ", other_excluded[, 2], ")", sep = ""), collapse = ""))
        } else {
          other_excluded_data <- paste0(":\n", paste(other_excluded[, 1], collapse = "\n"))
        }
      } else if (is.character(other_excluded) && length(other_excluded) == 1) {
        other_excluded_clean <- gsub('"', '', other_excluded)
        reasons <- strsplit(other_excluded_clean, "; ")[[1]]
        formatted_reasons <- sapply(reasons, function(reason) {
          parts <- strsplit(reason, ", ")[[1]]
          if (length(parts) == 2) {
            paste0(parts[1], " (n = ", parts[2], ")")
          } else {
            reason
          }
        })
        other_excluded_data <- paste0(":\n", paste(formatted_reasons, collapse = "\n"))
      } else {
        other_excluded_data <- paste0("\n(n = ", other_excluded, ")")
      }
    } else {
      other_excluded_data <- ""
    }
    
    # Labels
    other_identified_label <- paste0("Records identified from:", cond_websites, cond_citation, cond_organisation)
    other_sought_reports_label <- paste0("Records screened by reviewers\n(n = ", other_sought_reports, ")")
    other_notretrieved_label <- paste0("Records labelled not relevant\n(n = ", other_notretrieved_reports, ")")
    other_assessed_label <- paste0("Full-text reports assessed for eligibility\n(n = ", other_assessed, ")")
    other_excluded_label <- paste0("Reports excluded", other_excluded_data)
    
    # Calculate heights
    other_identified_height <- PRISMA_get_height_(stringr::str_count(other_identified_label, "\n"), min_box_height)
    other_sought_reports_height <- PRISMA_get_height_(stringr::str_count(other_sought_reports_label, "\n"), min_box_height)
    other_notretrieved_height <- PRISMA_get_height_(stringr::str_count(other_notretrieved_label, "\n"), min_box_height)
    other_assessed_height <- PRISMA_get_height_(stringr::str_count(other_assessed_label, "\n"), min_box_height)
    other_excluded_height <- PRISMA_get_height_(stringr::str_count(other_excluded_label, "\n"), min_box_height)
  }
  
  # Database section labels
  if (!is.na(new_studies) && new_studies > 0) {
    cond_newstud <- paste0(stringr::str_wrap("Studies included via database search", width = 40), "\n(n = ", new_studies, ")\n")
  } else {
    cond_newstud <- ""
  }
  
  if (!is.na(new_reports) && new_reports > 0) {
    cond_newreports <- paste0(stringr::str_wrap("Studies included via citations", width = 40), "\n(n = ", new_reports, ")")
  } else {
    cond_newreports <- ""
  }
  
  # Database details
  if (detail_databases == TRUE && exists("database_specific_results") && is.data.frame(database_specific_results)) {
    db_specific_data_nr <- paste(paste("\n", database_specific_results[, 1], " (n = ", database_specific_results[, 2], ")", sep = ""), collapse = "")
    db_specific_data <- paste0(":", db_specific_data_nr)
  } else {
    db_specific_data <- ""
    db_specific_data_nr <- ""
  }
  
  if (detail_registers == TRUE && exists("register_specific_results") && is.data.frame(register_specific_results)) {
    reg_specific_data_nr <- paste(paste("\n", register_specific_results[, 1], " (n = ", register_specific_results[, 2], ")", sep = ""), collapse = "")
    reg_specific_data <- paste0(":", reg_specific_data_nr)
  } else {
    reg_specific_data <- ""
    reg_specific_data_nr <- ""
  }
  
  # Database and register conditions
  if (!is.na(database_results) && database_results > 0) {
    cond_database <- paste0("\nDatabases (n = ", database_results, ")", db_specific_data)
  } else {
    cond_database <- paste0("", db_specific_data_nr)
  }
  
  if (!is.na(register_results) && register_results > 0) {
    cond_register <- paste0("\nRegisters (n = ", register_results, ")", reg_specific_data)
  } else {
    cond_register <- paste0("", reg_specific_data_nr)
  }
  
  # Exclusion data handling
  if (exists("dbr_excluded")) {
    if (is.character(dbr_excluded) && length(dbr_excluded) == 1) {
      dbr_excluded_clean <- gsub('"', '', dbr_excluded)
      reasons_with_numbers <- strsplit(dbr_excluded_clean, "; ")[[1]]
      formatted_reasons <- character(0)
      
      for (reason in reasons_with_numbers) {
        parts <- trimws(strsplit(reason, ",")[[1]])
        if (length(parts) == 2) {
          formatted_reason <- paste0(parts[1], " (n = ", parts[2], ")")
          formatted_reasons <- c(formatted_reasons, formatted_reason)
        }
      }
      dbr_excluded_data <- paste0(":\n", paste(formatted_reasons, collapse = "\n"))
    } else if (is.data.frame(dbr_excluded)) {
      dbr_excluded_data <- paste0(":", paste(paste("\n", dbr_excluded[, 1], " (n = ", dbr_excluded[, 2], ")", sep = ""), collapse = ""))
    } else {
      dbr_excluded_data <- paste0("\n(n = ", dbr_excluded, ")")
    }
  } else {
    dbr_excluded_data <- ""
  }
  
  # Duplicate conditions
  if (!is.na(duplicates) && duplicates > 0) {
    cond_duplicates <- paste0(stringr::str_wrap(paste0("Duplicate records (n = ", duplicates, ")"), width = 42), "\n")
  } else {
    cond_duplicates <- ""
  }
  
  if (!is.na(excluded_automatic) && excluded_automatic > 0) {
    cond_automatic <- paste0(stringr::str_wrap(paste0("Records marked as ineligible by automation tools (n = ", excluded_automatic, ")"), width = 42), "\n")
  } else {
    cond_automatic <- ""
  }
  
  if (!is.na(excluded_other) && excluded_other > 0) {
    cond_exclother <- paste0(stringr::str_wrap(paste0("Records removed for other reasons (n = ", excluded_other, ")"), width = 42))
  } else {
    cond_exclother <- ""
  }
  
  if ((is.na(duplicates) || duplicates == 0) && 
      (is.na(excluded_automatic) || excluded_automatic == 0) && 
      (is.na(excluded_other) || excluded_other == 0)) {
    cond_duplicates <- "(n = 0)"
  }
  
  # Main labels
  newstudy_newreports_label <- gsub('"', '\\"', paste0(cond_newstud, cond_newreports))
  dbr_assessed_label <- gsub('"', '\\"', paste0("Full-text reports assessed for eligibility\n(n = ", dbr_assessed, ")"))
  dbr_sought_label <- gsub('"', '\\"', paste0("Records screened by reviewers\n(n = ", dbr_sought_reports, ")"))
  dbr_screened_label <- gsub('"', '\\"', paste0("Records screened\n(n = ", records_screened, ")"))
  dbr_identified_label <- gsub('"', '\\"', paste0("Records identified from:", cond_database, cond_register))
  dbr_excluded_label <- gsub('"', '\\"', paste0("Reports excluded", dbr_excluded_data))
  dbr_notretrieved_label <- gsub('"', '\\"', paste0("Reports labelled not relevant\n(n = ", dbr_notretrieved_reports, ")"))
  dbr_screened_excluded_label <- gsub('"', '\\"', paste0("Records excluded by ASReview\n(n = ", records_excluded, ")"))
  dbr_notscreened_label <- gsub('"', '\\"', paste0("Records removed before screening:\n", cond_duplicates, cond_automatic, cond_exclother))
  
  # Calculate heights
  newstudy_newreports_height <- PRISMA_get_height_(stringr::str_count(newstudy_newreports_label, "\n"), min_box_height)
  dbr_assessed_height <- PRISMA_get_height_(stringr::str_count(dbr_assessed_label, "\n"), min_box_height)
  dbr_sought_height <- PRISMA_get_height_(stringr::str_count(dbr_sought_label, "\n"), min_box_height)
  dbr_screened_height <- PRISMA_get_height_(stringr::str_count(dbr_screened_label, "\n"), min_box_height)
  dbr_identified_height <- PRISMA_get_height_(stringr::str_count(dbr_identified_label, "\n"), min_box_height)
  dbr_excluded_height <- PRISMA_get_height_(stringr::str_count(dbr_excluded_label, "\n"), min_box_height)
  dbr_notretrieved_height <- PRISMA_get_height_(stringr::str_count(dbr_notretrieved_label, "\n"), min_box_height)
  dbr_screened_excluded_height <- PRISMA_get_height_(stringr::str_count(dbr_screened_excluded_label, "\n"), min_box_height)
  dbr_notscreened_height <- PRISMA_get_height_(stringr::str_count(dbr_notscreened_label, "\n"), min_box_height)
  
  # Box positioning calculations
  screening_box_height <- max(c(dbr_screened_height, dbr_screened_excluded_height)) + 
    max(c(dbr_notretrieved_height, dbr_sought_height, other_sought_reports_height, other_notretrieved_height)) + 
    max(c(dbr_assessed_height, dbr_excluded_height, other_assessed_height, other_excluded_height)) + 
    default_box_spacing * 3
  
  identification_box_height <- max(c(dbr_identified_height, dbr_notscreened_height, prev_study_height))
  included_box_height <- newstudy_newreports_height + total_studies_height + default_box_spacing
  
  assessed_height <- max(c(dbr_assessed_height, other_assessed_height, dbr_excluded_height, other_excluded_height))
  sought_height <- max(c(dbr_sought_height, other_sought_reports_height, dbr_notretrieved_height, other_notretrieved_height))
  screened_height <- max(c(dbr_screened_height, dbr_screened_excluded_height, citations_screened_height, citations_excluded_asreview_height))
  identified_height <- max(c(dbr_identified_height, dbr_notscreened_height, other_identified_height, prev_study_height, citations_duplicates_height))
  
  # X positions
  dbr_box_x <- PRISMA_get_pos_(diagram_start_x, prev_study_offset + default_box_spacing, prev_study_width, default_box_width)
  dbr_removed_x <- PRISMA_get_pos_(dbr_box_x, default_box_spacing, default_box_width, default_box_width)
  
  # Y positions
  newstudy_newreports_y <- PRISMA_get_pos_(diagram_start_y, default_box_spacing, total_studies_height, newstudy_newreports_height)
  assessed_y <- PRISMA_get_pos_(newstudy_newreports_y, default_box_spacing * 2, newstudy_newreports_height, assessed_height)
  sought_y <- PRISMA_get_pos_(assessed_y, default_box_spacing, assessed_height, sought_height)
  screened_y <- PRISMA_get_pos_(sought_y, default_box_spacing, sought_height, screened_height)
  identified_y <- PRISMA_get_pos_(screened_y, default_box_spacing * 2, screened_height, identified_height)
  top_box_y <- PRISMA_get_pos_(identified_y, default_box_spacing, identified_height, section_label_length)
  
  screening_y <- mean(c(screened_y, sought_y, assessed_y))
  included_y <- if (total_studies_height > 0) {
    mean(c(diagram_start_y, newstudy_newreports_y))
  } else {
    newstudy_newreports_y
  }
  
  # Side boxes with blank labels (JavaScript will add rotated text)
  if (side_boxes == TRUE) {
    sidebox <- paste0("node [\n shape = box,\n fontsize = ", fontsize, ",\n fontname = ", font, ",\n color = ", title_colour, "\n ]\n identification [\n color = LightSteelBlue2,\n label = ' ',\n style = 'filled,rounded',\n pos = '", diagram_start_x, ",", identified_y, "!',\n width = ", section_label_length, ",\n height = ", identification_box_height, ",\n tooltip = 'Identification'\n ];\n screening [\n color = LightSteelBlue2,\n label = ' ',\n style = 'filled,rounded',\n pos = '", diagram_start_x, ",", screening_y, "!',\n width = ", section_label_length, ",\n height = ", screening_box_height, ",\n tooltip = 'Screening'\n ];\n included [\n color = LightSteelBlue2,\n label = ' ',\n style = 'filled,rounded',\n pos = '", diagram_start_x, ",", included_y, "!',\n width = ", section_label_length, ",\n height = ", included_box_height, ",\n tooltip = 'Included'\n ];\n")
  } else {
    sidebox <- ""
  }
  
  # Previous studies section (simplified)
  if (previous == TRUE) {
    previous_nodes <- paste0("node [\n shape = box,\n fontsize = ", fontsize, ",\n fontname = ", font, ",\n color = ", greybox_colour, "\n ]\n")
  }
  
  # Other methods section
  if (other == TRUE) {
    other_box_x <- PRISMA_get_pos_(dbr_removed_x, default_box_spacing, default_box_width, default_box_width)
    other_removed_x <- PRISMA_get_pos_(other_box_x, default_box_spacing, default_box_width, default_box_width)
    
    B <- paste0("B [\n label = '',\n pos = '", other_box_x, ",", newstudy_newreports_y, "!',\n tooltip = ''\n ]")
    
    cluster2 <- paste0("subgraph cluster2 {\n edge [\n color = White,\n arrowhead = none,\n arrowtail = none\n ]\n 13->14;\n edge [\n color = ", arrow_colour, ",\n arrowhead = ", arrow_head, ",\n arrowtail = ", arrow_tail, "]\n 14->20;\n 14->21;\n 21->22;\n 21->15;\n 15->16;\n 15->17;\n 17->18;\n edge [\n color = ", arrow_colour, ",\n arrowhead = none,\n arrowtail = ", arrow_tail, "]\n 17->B;\n edge [\n color = ", arrow_colour, ",\n arrowhead = ", arrow_head, ",\n arrowtail = none,\n constraint = FALSE\n ]\n B->12;\n }")
    
    othernodes <- paste0("node [\n shape = box,\n fontname = ", font, ",\n color = ", greybox_colour, "]\n 13 [\n label = 'Identification of new studies via other methods',\n style = 'rounded,filled',\n width = ", top_box_width, ",\n height = ", section_label_length, ",\n pos = '", mean(c(other_box_x, other_removed_x)), ",", top_box_y, "!',\n tooltip = 'Other methods'\n ]\n 14 [\n label = '", other_identified_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", other_identified_height, ",\n pos = '", other_box_x, ",", identified_y, "!',\n tooltip = 'Records identified from other methods'\n ]\n 20 [\n label = '", citations_duplicates_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", citations_duplicates_height, ",\n pos = '", other_removed_x, ",", identified_y, "!',\n tooltip = 'Citation duplicates removed'\n ]\n 21 [\n label = '", citations_screened_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", citations_screened_height, ",\n pos = '", other_box_x, ",", screened_y, "!',\n tooltip = 'Citations screened'\n ]\n 22 [\n label = '", citations_excluded_asreview_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", citations_excluded_asreview_height, ",\n pos = '", other_removed_x, ",", screened_y, "!',\n tooltip = 'Citations excluded by ASReview'\n ]\n 15 [\n label = '", other_sought_reports_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", other_sought_reports_height, ",\n pos = '", other_box_x, ",", sought_y, "!',\n tooltip = 'Records screened by reviewers (other)'\n ]\n 16 [\n label = '", other_notretrieved_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", other_notretrieved_height, ",\n pos = '", other_removed_x, ",", sought_y, "!',\n tooltip = 'Records not retrieved (other)'\n ]\n 17 [\n label = '", other_assessed_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", other_assessed_height, ",\n pos = '", other_box_x, ",", assessed_y, "!',\n tooltip = 'Reports assessed for eligibility (other)'\n ]\n 18 [\n label = '", other_excluded_label, "',\n style = 'filled',\n width = ", default_box_width, ",\n height = ", other_excluded_height, ",\n pos = '", other_removed_x, ",", assessed_y, "!',\n tooltip = 'Reports excluded (other)'\n ]\n")
    
    extraedges <- "16->18; 20->22; 22->16;"
    othernode13 <- "; 13"
    othernode14 <- "; 14; 20"
    othernode1516 <- "; 15; 16"
    othernode1718 <- "; 17; 18"
    othernode2122 <- "; 21; 22"
    othernodeB <- "; B"
  } else {
    B <- ""
    cluster2 <- ""
    othernodes <- ""
    extraedges <- ""
    othernode13 <- ""
    othernode14 <- ""
    othernode1516 <- ""
    othernode1718 <- ""
    othernode2122 <- ""
    othernodeB <- ""
  }
  
  # Generate the complete diagram
  x <- DiagrammeR::grViz(paste0("digraph TD {\n graph[\n splines = ortho,\n layout = neato,\n tooltip = 'Click the boxes for further information',\n outputorder = edgesfirst,\n ]", 
                                sidebox, 
                                previous_nodes, 
                                "node [\n shape = box,\n fontsize = ", fontsize, ",\n fontname = ", font, ",\n color = ", title_colour, "]\n 3 [\n label = 'Identification of new studies via databases',\n style = 'rounded,filled',\n width = ", top_box_width, ",\n height = ", section_label_length, ",\n pos = '", mean(c(dbr_box_x, dbr_removed_x)), ",", top_box_y, "!',\n tooltip = 'New studies identification'\n ]\n node [\n shape = box,\n fontname = ", font, ",\n color = ", main_colour, "]\n 4 [\n label = '", dbr_identified_label, "',\n width = ", default_box_width, ",\n height = ", dbr_identified_height, ",\n pos = '", dbr_box_x, ",", identified_y, "!',\n tooltip = 'Database results'\n ]\n 5 [\n label = '", dbr_notscreened_label, "',\n width = ", default_box_width, ",\n height = ", min_box_height, ",\n pos = '", dbr_removed_x, ",", identified_y, "!',\n tooltip = 'Duplicates'\n ]\n 6 [\n label = '", dbr_screened_label, "',\n width = ", default_box_width, ",\n height = ", dbr_screened_height, ",\n pos = '", dbr_box_x, ",", screened_y, "!',\n tooltip = 'Records screened'\n ]\n 7 [\n label = '", dbr_screened_excluded_label, "',\n width = ", default_box_width, ",\n height = ", min_box_height, ",\n pos = '", dbr_removed_x, ",", screened_y, "!',\n tooltip = 'Records excluded'\n ]\n 8 [\n label = '", dbr_sought_label, "',\n width = ", default_box_width, ",\n height = ", dbr_sought_height, ",\n pos = '", dbr_box_x, ",", sought_y, "!',\n tooltip = 'Reports sought'\n ]\n 9 [\n label = '", dbr_notretrieved_label, "',\n width = ", default_box_width, ",\n height = ", min_box_height, ",\n pos = '", dbr_removed_x, ",", sought_y, "!',\n tooltip = 'Reports not retrieved'\n ]\n 10 [\n label = '", dbr_assessed_label, "',\n width = ", default_box_width, ",\n height = ", dbr_assessed_height, ",\n pos = '", dbr_box_x, ",", assessed_y, "!',\n tooltip = 'Reports assessed'\n ]\n 11 [\n label = '", dbr_excluded_label, "',\n width = ", default_box_width, ",\n height = ", min_box_height, ",\n pos = '", dbr_removed_x, ",", assessed_y, "!',\n tooltip = 'Reports excluded',\n fillcolor = White,\n style = filled\n ]\n 12 [\n label = '", newstudy_newreports_label, "',\n width = ", default_box_width, ",\n height = ", newstudy_newreports_height, ",\n pos = '", dbr_box_x, ",", newstudy_newreports_y, "!',\n tooltip = 'New studies'\n ]", 
                                othernodes, 
                                finalnode, 
                                "node [\n shape = square,\n width = 0,\n color=White\n ]\n", A, "\n", B, "\n", Aedge, 
                                "node [\n shape = square,\n width = 0,\n style=invis\n ]\n C [\n label = '',\n width = ", default_box_width, ",\n height = ", min_box_height, ",\n pos = '", dbr_removed_x, ",", assessed_y, "!',\n tooltip = ''\n ]\n subgraph cluster1 {\n edge [\n style = invis\n ]\n 3->4;\n 3->5;\n edge [\n color = ", arrow_colour, ",\n arrowhead = ", arrow_head, ",\n arrowtail = ", arrow_tail, ",\n style = filled\n ]\n 4->5;\n 4->6;\n 6->7;\n 6->8;\n 8->9;\n 8->10;\n 10->C;\n 10->12;\n edge [\n style = invis\n ]\n 5->7;\n 7->9;\n 9->11;\n ", extraedges, "\n }", 
                                cluster2, "\n", bottomedge, "\n\n", prev_rank1, "\n", 
                                "{\n rank = same; ", prevnode1, "3", othernode13, "}\n {\n rank = same; ", prevnode2, "4; 5", othernode14, "}\n {\n rank = same; 6; 7", othernode2122, "}\n {\n rank = same; 8; 9", othernode1516, "}\n {\n rank = same; 10; 11", othernode1718, "}\n {\n rank = same; 12", othernodeB, "}\n }"))
  
  # Apply JavaScript for rotated side box labels
  if (side_boxes == TRUE) {
    x <- PRISMA_insert_js_(x, 
                           identification_text = "Identification", 
                           screening_text = "Screening", 
                           included_text = "Included")
  }
  
  # Apply interactive features if requested
  if (interactive == TRUE) {
    x <- PRISMA_interactive_(x, urls = data$urls, previous = previous, other = other)
  }
  
  return(x)
}