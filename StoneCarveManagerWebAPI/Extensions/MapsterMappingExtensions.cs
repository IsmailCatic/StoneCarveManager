using Mapster;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Entities;

namespace StoneCarveManagerWebAPI.Extensions
{
    public static class MapsterMappingExtensions
    {
        public static void RegisterMapsterMappings(this TypeAdapterConfig config)
        {
            // User -> UserDTO
            config.NewConfig<User, UserDTO>()
                .Map(dest => dest.Roles, src => src.UserRoles.Select(ur => ur.RoleId.ToString()));

            // BlogPost -> BlogPostResponse
            config.NewConfig<BlogPost, BlogPostResponse>()
                .Map(dest => dest.CategoryName, src => src.Category.Name);

            // Order -> OrderResponse
            //config.NewConfig<Order, OrderResponse>()
            //    .Map(dest => dest.ClientName, src => src.User.FirstName + " " + src.User.LastName)
            //    .Map(dest => dest.ClientEmail, src => src.User.Email);

            TypeAdapterConfig<Order, OrderResponse>
                .NewConfig()
                .Map(dest => dest.ClientName,
                     src => src.User != null
                         ? src.User.FirstName + " " + src.User.LastName
                         : null)
                .Map(dest => dest.ClientEmail,
                     src => src.User != null
                         ? src.User.Email
                         : null);


            TypeAdapterConfig<OrderProgressImage, OrderProgressImageResponse>
                .NewConfig()
                .Map(dest => dest.UploadedByUserName,
                     src => src.UploadedByUser != null
                         ? src.UploadedByUser.FirstName + " " + src.UploadedByUser.LastName
                         : null);

            TypeAdapterConfig<OrderUpdateRequest, Order>
                .NewConfig()
                .IgnoreNullValues(true);

            TypeAdapterConfig<OrderItem, OrderItemResponse>.NewConfig()
                 .Map(dest => dest.TotalPrice, src => src.TotalPrice);

            // OrderStatusHistory -> OrderStatusHistoryResponse
            TypeAdapterConfig<OrderStatusHistory, OrderStatusHistoryResponse>
                .NewConfig()
                .Map(dest => dest.ChangedByUserName,
                     src => src.ChangedByUser != null
                         ? src.ChangedByUser.FirstName + " " + src.ChangedByUser.LastName
                         : null);


            config.NewConfig<OrderItem, OrderItemResponse>()
                .Map(dest => dest.ProductName, src => src.Product != null ? src.Product.Name : null)
                .Map(dest => dest.ProductState, src => src.Product != null ? src.Product.ProductState : null); // ✅ NOVO

            // OrderProgressImage -> OrderProgressImageResponse
            //config.NewConfig<OrderProgressImage, OrderProgressImageResponse>()
            //    .Map(dest => dest.UploadedByUserName,
            //         src => src.UploadedByUser != null
            //         ? src.UploadedByUser.FirstName + " " + src.UploadedByUser.LastName
            //         : null);

            // Dodaj dalje custom profile ako treba...
        }
    }
}
