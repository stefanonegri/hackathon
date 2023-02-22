import ballerina/http;
//import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;
//import ballerina/graphql;
//import ballerina/log;


      public type Person record {|
    string name;
    int age;
|};
   
   public type Catalogue record {|
    int ItemId?;
    string Title;
    string Description;
    string Includes?;
    string IntendedFor?;
    string Material?;
    string Image?;
    string Price;
|};

public type ChartInsert record {|
    int ItemId?;
    int CatalogueId;
    string UserId;
    int Quantity;
|};

public type ChartQuery record {|
    int ItemId?;
    string Title;
    string UserId;
    int Quantity;
|};
//table<Catalogue> key(ItemId) catalogueTable = table [
//    {ItemId: 1, Title: "Top Paw", Description: "Top Paw Dog Food", Includes: "Dog Food", IntendedFor: "Dogs", Material: "Plastic", Image: "https://assets.petco.com/petco/image/upload/f_auto,q_auto:best,w_176/spring-shop_apparel_quicktiles_top-categories_onesies-and-pajamas_200x209.png", Price: "10.00"},
//    {ItemId: 2, Title: "Arcadia Trai", Description: "The right jacket for your pet", Includes: "jacket", IntendedFor: "Dogs", Material: "Cotton", Image: "https://www.petco.com/shop/medias/sys_master/images/images/hc9/hc9/11793210030366.jpg", Price: "20.00"}
//];




service / on new http:Listener(9090) {
    private final mysql:Client db;

     function init() returns error?{
        
       // jdbc:Client|error jdbcEp1 = new (url = "jdbc:mysql://sahackathon.mysql.database.azure.com:3306/stefano_db?useSSL=true", user = "choreo", password = "wso2!234");
      self.db = check new ("sahackathon.mysql.database.azure.com", "choreo", "wso2!234", "stefano_db", 3306);
      
    }
       

      resource function get catalogue() returns Catalogue[]|error? {
        io:println("Querying table 'catalogue'...");
        
        stream<Catalogue, error?> catalogueStream =  self.db->query(`SELECT * FROM catalogue`);

       return from Catalogue cat in catalogueStream
            select   cat;

      
        }
        
     
     resource function get catalogue/[string id]() returns Catalogue|http:NotFound|error {
        io:println("Querying table 'catalogue'...");
        
        Catalogue|sql:Error result = self.db->queryRow(`SELECT * FROM catalogue WHERE ItemID = ${id}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
        
    }

        resource function post catalogue(@http:Payload Catalogue catalogue) returns int {
        //catalogueTable.add(catalogue);

        io:println("Inserting data to table 'catalogue'...");
        //io:println(catalogue.Title);
        sql:ParameterizedQuery query = `INSERT INTO catalogue(Title, Description, Includes, IntendedFor, Material, Image, Price)
                                  VALUES (${catalogue.Title}, ${catalogue.Description}, ${catalogue.Includes}, ${catalogue.IntendedFor}, ${catalogue.Material}, ${catalogue.Image}, ${catalogue.Price})`;
            sql:ExecutionResult|sql:Error result = self.db->execute(query);
            if result is sql:ExecutionResult {
                io:println("Inserted row count to 'catalogue' table: ", result?.affectedRowCount);
                return 1;
               
            }else {
                io:println("Error: ", result);
                return 0;
            }
        
    }

        resource function put catalogue/[int id](@http:Payload Catalogue catalogue) returns int {
        io:println("Updating record in 'catalogue'; Record id: ", id);
        //io:println(catalogue.Title);
        sql:ParameterizedQuery query = `UPDATE catalogue SET Title = ${catalogue.Title}, Description = ${catalogue.Description}, Includes = ${catalogue.Includes}, IntendedFor = ${catalogue.IntendedFor}, Material = ${catalogue.Material}, Image = ${catalogue.Image}, Price = ${catalogue.Price} WHERE ItemId = ${id}`;
                               
            sql:ExecutionResult|sql:Error result = self.db->execute(query);
            if result is sql:ExecutionResult {
                io:println("Updated record in 'cataogue' table: ", result?.affectedRowCount);
                return 1;
               
            }else {
                io:println("Error: ", result);
                return 0;
            }

}



        resource function get chart/[string userId]() returns ChartQuery[]|sql:Error? {
        // Execute simple query to retrieve all records from the `albums` table.
            stream<ChartQuery, sql:Error?> chartStream = self.db->query(`SELECT chart.ItemId, catalogue.Title, chart.UserId, chart.Quantity FROM chart, catalogue WHERE chart.userId = ${userId} AND chart.CatalogueId = catalogue.ItemId`);

        // Process the stream and convert results to Album[] or return error.
        return from ChartQuery chart in chartStream
            select chart;
    }

        resource function post chart(@http:Payload ChartInsert chart) returns int {
        //catalogueTable.add(catalogue);

        io:println("Inserting data to table 'chart'...");
        //io:println(catalogue.Title);
        sql:ParameterizedQuery query = `INSERT INTO chart(CatalogueId, UserId, Quantity)
                                  VALUES (${chart.CatalogueId}, ${chart.UserId}, ${chart.Quantity})`;
            sql:ExecutionResult|sql:Error result = self.db->execute(query);
            if result is sql:ExecutionResult {
                io:println("Inserted row count to 'chart' table: ", result?.affectedRowCount);
                return 1;
               
            }else {
                io:println("Error: ", result);
                return 0;
            }
        
    }

}

//service /graphql on new graphql:Listener(9091) {

    // Ballerina GraphQL resolvers can return `record` values. The record will be mapped to a
    // GraphQL output object type in the generated GraphQL schema with the same name and fields.
  // private final mysql:Client db;

   
  // function init() returns error?{
        
       // jdbc:Client|error jdbcEp1 = new (url = "jdbc:mysql://sahackathon.mysql.database.azure.com:3306/stefano_db?useSSL=true", user = "choreo", password = "wso2!234");
  //    self.db = check new ("sahackathon.mysql.database.azure.com", "choreo", "wso2!234", "stefano_db", 3306);
      
 //   }
   
 //   resource function get catalogue() returns Catalogue[]|error? {
        
 //       stream<Catalogue, error?> catalogueStream =  self.db->query(`SELECT * FROM catalogue`);

 //      return from Catalogue catalogue in catalogueStream
 //           select   catalogue;

        // Process the stream and convert results to Album[] or return error.
       
     //  Catalogue c1 = { ItemId: 1, Title: "Arcadia Trai", Description: "The right jacket for your pet", Includes: "jacket", IntendedFor: "Dogs", Material: "Cotton", Image: "https://www.petco.com/shop/medias/sys_master/images/images/hc9/hc9/11793210030366.jpg", Price: "20.00"};
     //  Catalogue c2 = { ItemId: 1, Title: "Arcadia Trai", Description: "The right jacket for your pet", Includes: "jacket", IntendedFor: "Dogs", Material: "Cotton", Image: "https://www.petco.com/shop/medias/sys_master/images/images/hc9/hc9/11793210030366.jpg", Price: "20.00"};
     //   return [c1, c2];
        
  //  }


//}
