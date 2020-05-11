//
//  Database.swift
//  Image Stream
//
//  Created by Joshua Grant on 5/10/20.
//  Copyright © 2020 Joshua Grant. All rights reserved.
//

import CoreData

typealias Context = NSManagedObjectContext

class Database
{
	static var container: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Image_Stream")
		container.loadPersistentStores { description, error in
			if let error = error
			{
				fatalError(error.localizedDescription)
			}
		}
		return container
	}()
	
	static var context: Context { container.viewContext }
	
	static func save()
	{
		let context = container.viewContext
		if context.hasChanges
		{
			do
			{
				try context.save()
			}
			catch
			{
				fatalError("Failed to save: \(error)")
			}
		}
	}
}
